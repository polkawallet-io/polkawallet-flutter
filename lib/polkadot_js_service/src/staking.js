import store from "store";
import BN from "bn.js";

import { createType, TypeRegistry } from "@polkadot/types";
import { bnMax, u8aToU8a, formatBalance, formatNumber } from "@polkadot/util";

// use the same key with polkadot-js/apps
const STORAGE_KEY = "hooks:sessionSlashes";
const MAX_SESSIONS = 10 * (12 / 4);
// const MAX_SESSIONS = 10;
const MAX_BLOCKS = 2500;
const registry = new TypeRegistry();
const divisor = new BN(
  "1".padEnd(formatBalance.getDefaults().decimals + 1, "0")
);

function _fromJSON(sessions) {
  let keepAll = false;

  return (
    sessions
      .map(
        ({
          blockHash,
          blockNumber,
          isEventsEmpty,
          parentHash,
          reward,
          sessionIndex,
          slashes,
          treasury
        }) => ({
          blockHash: createType(registry, "Hash", blockHash),
          blockNumber: createType(registry, "BlockNumber", blockNumber),
          isEventsEmpty,
          parentHash: createType(registry, "Hash", parentHash),
          reward: createType(registry, "Balance", reward),
          sessionIndex: createType(registry, "SessionIndex", sessionIndex),
          slashes: slashes.map(({ accountId, amount }) => ({
            accountId: createType(registry, "AccountId", accountId),
            amount: createType(registry, "Balance", amount)
          })),
          treasury: createType(registry, "Balance", treasury)
        })
      )
      .filter(({ parentHash }) => !parentHash.isEmpty)
      .reverse()
      // we drop everything before the last reward
      .filter(({ reward }) => {
        if (reward.gtn(0)) {
          keepAll = true;
        }

        return keepAll;
      })
      .reverse()
  );
}

function _toJSON(sessions, maxSessions) {
  return sessions
    .map(
      ({
        blockHash,
        blockNumber,
        isEventsEmpty,
        parentHash,
        reward,
        sessionIndex,
        slashes,
        treasury
      }) => ({
        blockHash: blockHash.toHex(),
        blockNumber: blockNumber.toHex(),
        isEventsEmpty,
        parentHash: parentHash.toHex(),
        reward: reward.toHex(),
        sessionIndex: sessionIndex.toHex(),
        slashes: slashes.map(({ accountId, amount }) => ({
          accountId: accountId.toString(),
          amount: amount.toHex()
        })),
        treasury: treasury.toHex()
      })
    )
    .slice(-maxSessions);
}

async function _loadSome(fromHash, toHash) {
  const results = await api.rpc.state
    .queryStorage([api.query.session.currentIndex.key()], fromHash, toHash)
    .catch(() => []);
  window.send("log", "query storage length: " + results.length);
  const headers = await Promise.all(
    results.map(({ block }) => api.rpc.chain.getHeader(block))
  );
  const events = await Promise.all(
    results.map(({ block }) =>
      api.query.system.events
        .at(block)
        .then(records =>
          records.filter(({ event: { section } }) => section === "staking")
        )
        .catch(() => [])
    )
  );
  const slashes = events.map(info =>
    info
      .filter(({ event: { method } }) => method === "Slash")
      .map(({ event: { data: [accountId, amount] } }) => ({
        accountId,
        amount
      }))
  );
  const rewards = events.map(info => {
    const rewards = info.filter(({ event: { method } }) => method === "Reward");
    return [rewards[0]?.event?.data[0], rewards[0]?.event?.data[1]];
  });

  return results
    .filter(({ changes }) => !!(changes && changes.length))
    .map(({ changes: [[, value]] }, index) => ({
      blockHash: headers[index].hash,
      blockNumber: headers[index].number.unwrap(),
      isEventsEmpty: events[index].length === 0,
      parentHash: headers[index].parentHash,
      reward: rewards[index][0] || createType(registry, "Balance"),
      sessionIndex: createType(
        registry,
        "SessionIndex",
        u8aToU8a(value.isSome ? value.unwrap() : new Uint8Array([]))
      ),
      slashes: slashes[index],
      treasury: rewards[index][1] || createType(registry, "Balance")
    }));
}

function _mergeResults(sessions, newSessions) {
  const tmp = sessions
    .concat(newSessions)
    .sort((a, b) => a.blockNumber.cmp(b.blockNumber));

  // for the first, always use it, otherwise ignore on same sessionIndex
  return tmp.filter(
    ({ sessionIndex }, index) =>
      index === 0 || !tmp[index - 1].sessionIndex.eq(sessionIndex)
  );
}

async function _loadSessionRewards(api, maxSessions) {
  let filtered = [];
  let workQueue = _fromJSON(store.get(STORAGE_KEY) || []);
  // let workQueue = _fromJSON([]);
  const savedNumber = workQueue[workQueue.length - 1]
    ? workQueue[workQueue.length - 1].blockNumber
    : undefined;

  const maxSessionsStore = maxSessions + 1; // assuming first is a bust
  const bestHeader = await api.rpc.chain.getHeader();
  let toHash = bestHeader.hash;
  let toNumber = bestHeader.number.unwrap().toBn();
  let fromNumber = bnMax(toNumber.subn(MAX_BLOCKS), new BN(1));

  while (true) {
    // console.log(`Updating rewards cache, #${fromNumber} -> #${toNumber}`);
    const fromHash = await api.rpc.chain.getBlockHash(fromNumber);
    window.send("log", "from-to: " + fromNumber + "-" + toNumber);
    window.send("log", fromHash.toHex());
    window.send("log", toHash.toHex());
    const newQueue = await _loadSome(api, fromHash, toHash);

    workQueue = _mergeResults(workQueue, newQueue);
    toHash = fromHash;
    toNumber = fromNumber;
    fromNumber = bnMax(toNumber.subn(MAX_BLOCKS), new BN(1));

    store.set(STORAGE_KEY, _toJSON(workQueue, maxSessionsStore));
    filtered = workQueue.slice(-maxSessions);

    const lastNumber = workQueue[workQueue.length - 1]?.blockNumber;

    if (
      !lastNumber ||
      fromNumber.eqn(1) ||
      (workQueue.length >= maxSessionsStore &&
        fromNumber.lt(savedNumber || lastNumber))
    ) {
      break;
    }
  }

  return filtered;
}

async function _getBlockCounts(api, accountId, sessionRewards) {
  const sessionIndex = await api.query.session.currentIndex();
  const current = await api.query.imOnline?.authoredBlocks(
    sessionIndex,
    accountId
  );

  let historic = await Promise.all(
    sessionRewards.map(({ parentHash, sessionIndex }) =>
      api.query.imOnline.authoredBlocks
        .at(parentHash, parseInt(sessionIndex) - 1, accountId)
        .then(res => res.toNumber())
    )
  );

  return [...historic, current.toNumber()].slice(1);
}

function _extractEraSlash(validatorId, slashes) {
  return slashes.reduce((total, { accountId, amount }) => {
    return accountId.eq(validatorId) ? total.sub(amount) : total;
  }, new BN(0));
}

function _balanceToNumber(amount, divisor) {
  return (
    amount
      .muln(1000)
      .div(divisor)
      .toNumber() / 1000
  );
}

function _extractRewardData(validatorId, blockCounts, sessionRewards) {
  const rewardsLabels = [];
  const rewardsChart = [[], [], []];
  let total = new BN(0);
  let lastRewardIndex = 0;
  let rewardCount = 0;

  // we only work from the second position, the first deemed incomplete
  sessionRewards.forEach(
    ({ blockNumber, reward, sessionIndex, slashes }, index) => {
      // we are trying to find the first index where rewards are allocated, this is our start
      // since we only want complete eras, this means we drop some at the start
      if (lastRewardIndex === 0) {
        if (index && reward.gtn(0)) {
          lastRewardIndex = index;
        }

        return;
      }
      // slash is extracted from the available slashes
      const neg = _extractEraSlash(validatorId, slashes);
      // start of a new session, use the counts for the previous
      const totalBlocks = blockCounts
        .filter(
          (count, countIndex) =>
            !!count && countIndex >= lastRewardIndex && countIndex < index
        )
        .reduce((total, count) => total.addn(count - 0), new BN(0));
      // calculate the rewards based on our total share
      const pos = reward
        .mul(totalBlocks)
        .div(blockNumber.sub(sessionRewards[lastRewardIndex].blockNumber));
      // add this to the total
      total = total.add(neg).add(pos);
      rewardCount++;
      // if we have a reward here, set the reward index for the next iteration
      if (reward.gtn(0)) {
        lastRewardIndex = index;
      }
      // this shows the start of the new era, however rewards are for previous
      rewardsLabels.push(formatNumber(sessionIndex.subn(1)));
      // calculate and format to 3 decimals
      rewardsChart[0].push(_balanceToNumber(neg, divisor));
      rewardsChart[1].push(_balanceToNumber(pos, divisor));
      rewardsChart[2].push(_balanceToNumber(total.divn(rewardCount), divisor));
    }
  );

  return { rewardsChart, rewardsLabels };
}

async function loadValidatorRewardsData(api, validatorId) {
  const sessionRewards = await _loadSessionRewards(api, MAX_SESSIONS);
  const blockCounts = await _getBlockCounts(api, validatorId, sessionRewards);

  return _extractRewardData(validatorId, blockCounts, sessionRewards);
}

async function _getHistoric(atQuery, params, hashes) {
  return Promise.all(
    hashes.map(hash => atQuery(hash, ...params))
  ).then(results => results.map((value, index) => [hashes[index], value]));
}

function _extractStake(values, divisor) {
  return [
    values.map(([, { total }]) => _balanceToNumber(total.unwrap(), divisor))
  ];
}

function _extractSplit(values, validatorId) {
  if (!values.length) {
    return null;
  }

  const last = values[values.length - 1][1];
  const total = last.total.unwrap();

  if (total.eqn(0)) {
    return null;
  }

  const currency = formatBalance.getDefaults().unit;

  return [{ accountId: validatorId, isOwn: true, value: last.own.unwrap() }]
    .concat(
      last.others.map(({ who, value }) => ({
        accountId: who.toString(),
        isOwn: false,
        value: value.unwrap()
      }))
    )
    .sort((a, b) => b.value.cmp(a.value))
    .map(({ accountId, isOwn, value }) => {
      const label = toShortAddress(accountId);
      const percentage =
        value
          .muln(10000)
          .div(total)
          .toNumber() / 100;
      const tooltip = `${formatBalance(value, {
        forceUnit: "-",
        withSi: false
      })} ${currency} (${percentage.toFixed(2)}%)`;

      return {
        colors: isOwn ? COLORS_MINE : COLORS_OTHER,
        label,
        tooltip,
        value: percentage
      };
    });
}

async function loadValidatorStakeData(api, validatorId) {
  const sessionRewards = await _loadSessionRewards(api, MAX_SESSIONS);
  const hashes = sessionRewards.map(({ blockHash }) => blockHash);
  const stakeLabels = sessionRewards.map(({ sessionIndex }) =>
    formatNumber(sessionIndex)
  );

  const values = await _getHistoric(
    api.query.staking.stakers.at,
    [validatorId],
    hashes
  );
  const stakeChart = _extractStake(values, divisor);
  const splitChart = _extractSplit(values, validatorId);
  const splitMax = splitChart
    ? Math.min(Math.ceil(splitChart[0].value), 100)
    : 100;

  window.send("log", stakeChart);
  window.send("log", stakeLabels);
  window.send("log", splitChart);
  window.send("log", splitMax);
  return [];
}

export default {
  loadValidatorRewardsData
  // extractStake error
  //   loadValidatorStakeData
};
