import BN from "bn.js";
import { u8aConcat, u8aToHex } from "@polkadot/util";
import { BN_ONE, BN_ZERO, formatBalance, formatNumber } from "@polkadot/util";

const divisor = new BN("1".padEnd(12 + 1, "0"));

function balanceToNumber(amount) {
  return (
    amount
      .muln(1000)
      .div(divisor)
      .toNumber() / 1000
  );
}

function _extractRewards(erasRewards, ownSlashes, allPoints) {
  const labels = [];
  const slashSet = [];
  const rewardSet = [];
  const avgSet = [];
  let avgCount = 0;
  let total = 0;

  erasRewards.forEach(({ era, eraReward }) => {
    const points = allPoints.find((points) => points.era.eq(era));
    const slashed = ownSlashes.find((slash) => slash.era.eq(era));
    const reward = points?.eraPoints.gtn(0)
      ? balanceToNumber(
          points.points.mul(eraReward).div(points.eraPoints),
          divisor
        )
      : 0;
    const slash = slashed ? balanceToNumber(slashed.total, divisor) : 0;

    total += reward;

    if (reward > 0) {
      avgCount++;
    }

    labels.push(era.toHuman());
    rewardSet.push(reward);
    avgSet.push((avgCount ? Math.ceil((total * 100) / avgCount) : 0) / 100);
    slashSet.push(slash);
  });

  return {
    chart: [slashSet, rewardSet, avgSet],
    labels,
  };
}

function _extractPoints(points) {
  const labels = [];
  const avgSet = [];
  const idxSet = [];
  let avgCount = 0;
  let total = 0;

  points.forEach(({ era, points }) => {
    total += points.toNumber();
    labels.push(era.toHuman());

    if (points.gtn(0)) {
      avgCount++;
    }

    avgSet.push((avgCount ? Math.ceil((total * 100) / avgCount) : 0) / 100);
    idxSet.push(points);
  });

  return {
    chart: [idxSet, avgSet],
    labels,
  };
}
function _extractStake(exposures) {
  const labels = [];
  const cliSet = [];
  const expSet = [];
  const avgSet = [];
  let avgCount = 0;
  let total = 0;

  exposures.forEach(({ clipped, era, exposure }) => {
    const cli = balanceToNumber(clipped.total.unwrap(), divisor);
    const exp = balanceToNumber(exposure.total.unwrap(), divisor);

    total += cli;

    if (cli > 0) {
      avgCount++;
    }

    avgSet.push((avgCount ? Math.ceil((total * 100) / avgCount) : 0) / 100);
    labels.push(era.toHuman());
    cliSet.push(cli);
    expSet.push(exp);
  });

  return {
    chart: [cliSet, expSet, avgSet],
    labels,
  };
}

async function loadValidatorRewardsData(api, validatorId) {
  const ownSlashes = await api.derive.staking.ownSlashes(validatorId, true);
  const erasRewards = await api.derive.staking.erasRewards();
  const stakerPoints = await api.derive.staking.stakerPoints(validatorId, true);
  const ownExposure = await api.derive.staking.ownExposures(validatorId, true);

  const points = _extractPoints(stakerPoints);
  const rewards = _extractRewards(erasRewards, ownSlashes, stakerPoints);
  const stakes = _extractStake(ownExposure);
  return { points, rewards, stakes };
}

function _groupRewardsByValidator(stashId, rewards) {
  const grouped = [];
  rewards.forEach((reward) => {
    Object.entries(reward.validators).forEach(([validatorId, { value }]) => {
      const entry = grouped.find((entry) => entry.validatorId === validatorId);

      if (entry) {
        const eraEntry = entry.eras.find((entry) => entry.era.eq(reward.era));

        if (eraEntry) {
          eraEntry.stashes[stashId] = value;
        } else {
          entry.eras.push({
            era: reward.era,
            stashes: { [stashId]: value },
          });
        }

        entry.available = entry.available.add(value);
      } else {
        grouped.push({
          available: value,
          eras: [
            {
              era: reward.era,
              stashes: { [stashId]: value },
            },
          ],
          validatorId,
        });
      }
    });
  });
  return grouped.map((i) => ({ ...i, available: i.available.toString() }));
}

async function loadAccountRewardsData(address) {
  const rewards = await api.derive.staking.stakerRewards(address);
  const available = rewards.reduce(
    (result, { validators }) =>
      Object.values(validators).reduce(
        (result, { value }) => result.iadd(value),
        result
      ),
    new BN(0)
  );
  return {
    rewards,
    available: available.toString(),
    validators: _groupRewardsByValidator(address, rewards),
  };
}

function _accountsToString(accounts) {
  return accounts.map((accountId) => accountId.toString());
}

function _filterAccounts(accounts = [], without) {
  return accounts.filter((accountId) => !without.includes(accountId));
}

function _getNominators(nominations) {
  return nominations.reduce((mapped, [key, optNoms]) => {
    if (optNoms.isSome) {
      const nominatorId = key.args[0].toString();

      optNoms.unwrap().targets.forEach((_validatorId, index) => {
        const validatorId = _validatorId.toString();
        const info = [nominatorId, index + 1];

        if (!mapped[validatorId]) {
          mapped[validatorId] = [info];
        } else {
          mapped[validatorId].push(info);
        }
      });
    }

    return mapped;
  }, {});
}

async function fetchStakingOverview() {
  const data = await Promise.all([
    api.derive.staking.overview(),
    api.derive.staking.stashes(),
    api.query.staking.nominators.entries(),
  ]);
  const stakingOverview = data[0];
  const allStashes = _accountsToString(data[1]);
  const next = allStashes.filter(
    (e) => !stakingOverview.validators.includes(e)
  );
  const nominators = _getNominators(data[2]);

  const allElected = _accountsToString(stakingOverview.nextElected);
  const validatorIds = _accountsToString(stakingOverview.validators);
  const validators = _filterAccounts(validatorIds, []);
  const elected = _filterAccounts(allElected, validatorIds);
  const waiting = _filterAccounts(next, allElected);

  return {
    elected,
    validators,
    waiting,
    nominators,
  };
}

async function _getOwnStash(accountId) {
  let stashId = accountId;
  let isOwnStash = false;
  const ownStash = await Promise.all([
    api.query.staking.bonded(accountId),
    api.query.staking.ledger(accountId),
  ]);
  if (ownStash[0].isSome) {
    isOwnStash = true;
  }
  if (ownStash[1].isSome) {
    stashId = ownStash[1].unwrap().stash.toString();
    if (accountId != stashId) {
      isOwnStash = false;
    }
  }
  return [stashId, isOwnStash];
}

function _toIdString(id) {
  return id ? id.toString() : null;
}

function _extractStakerState(
  accountId,
  stashId,
  allStashes,
  [
    isOwnStash,
    {
      controllerId: _controllerId,
      exposure,
      nextSessionIds,
      nominators,
      rewardDestination,
      sessionIds,
      stakingLedger,
      validatorPrefs,
    },
    validateInfo,
  ]
) {
  const isStashNominating = !!nominators?.length;
  const isStashValidating =
    !(Array.isArray(validateInfo)
      ? validateInfo[1].isEmpty
      : validateInfo.isEmpty) || !!allStashes?.includes(stashId);
  const nextConcat = u8aConcat(...nextSessionIds.map((id) => id.toU8a()));
  const currConcat = u8aConcat(...sessionIds.map((id) => id.toU8a()));
  const controllerId = _toIdString(_controllerId);

  return {
    controllerId,
    destination: rewardDestination?.toString().toLowerCase(),
    destinationId: rewardDestination?.toNumber() || 0,
    exposure,
    hexSessionIdNext: u8aToHex(nextConcat, 48),
    hexSessionIdQueue: u8aToHex(
      currConcat.length ? currConcat : nextConcat,
      48
    ),
    isOwnController: accountId == controllerId,
    isOwnStash,
    isStashNominating,
    isStashValidating,
    // we assume that all ids are non-null
    nominating: nominators?.map(_toIdString),
    sessionIds: (nextSessionIds.length ? nextSessionIds : sessionIds).map(
      _toIdString
    ),
    stakingLedger,
    stashId,
    validatorPrefs,
  };
}

function _extractInactiveState(
  api,
  stashId,
  slashes,
  nominees,
  activeEra,
  submittedIn,
  exposures
) {
  const max = api.consts.staking?.maxNominatorRewardedPerValidator;

  // chilled
  const nomsChilled = nominees.filter((_, index) => {
    if (slashes[index].isNone) {
      return false;
    }

    const { lastNonzeroSlash } = slashes[index].unwrap();

    return !lastNonzeroSlash.isZero() && lastNonzeroSlash.gte(submittedIn);
  });

  // all nominations that are oversubscribed
  const nomsOver = exposures
    .map(({ others }) =>
      others.sort((a, b) => b.value.unwrap().cmp(a.value.unwrap()))
    )
    .map((others, index) =>
      !max || max.gtn(others.map(({ who }) => who.toString()).indexOf(stashId))
        ? null
        : nominees[index]
    )
    .filter((nominee) => !!nominee && !nomsChilled.includes(nominee));

  // first a blanket find of nominations not in the active set
  let nomsInactive = exposures
    .map((exposure, index) =>
      exposure.others.some(({ who }) => who.eq(stashId))
        ? null
        : nominees[index]
    )
    .filter((nominee) => !!nominee);

  // waiting if validator is inactive or we have not submitted long enough ago
  const nomsWaiting = exposures
    .map((exposure, index) =>
      exposure.total.unwrap().isZero() ||
      (nomsInactive.includes(nominees[index]) && submittedIn.eq(activeEra))
        ? nominees[index]
        : null
    )
    .filter((nominee) => !!nominee)
    .filter(
      (nominee) => !nomsChilled.includes(nominee) && !nomsOver.includes(nominee)
    );

  // filter based on all inactives
  const nomsActive = nominees.filter(
    (nominee) =>
      !nomsInactive.includes(nominee) &&
      !nomsChilled.includes(nominee) &&
      !nomsOver.includes(nominee)
  );

  // inactive also contains waiting, remove those
  nomsInactive = nomsInactive.filter(
    (nominee) =>
      !nomsWaiting.includes(nominee) &&
      !nomsChilled.includes(nominee) &&
      !nomsOver.includes(nominee)
  );

  return {
    nomsActive,
    nomsChilled,
    nomsInactive,
    nomsOver,
    nomsWaiting,
  };
}
async function _getInactives(stashId, nominees) {
  const indexes = await api.derive.session.indexes();
  const [optNominators, ...exposuresAndSpans] = await Promise.all(
    [api.query.staking.nominators(stashId)]
      .concat(
        nominees.map((id) =>
          api.query.staking.erasStakers(indexes.activeEra, id)
        )
      )
      .concat(nominees.map((id) => api.query.staking.slashingSpans(id)))
  );
  const exposures = exposuresAndSpans.slice(0, nominees.length);
  const slashes = exposuresAndSpans.slice(nominees.length);
  return _extractInactiveState(
    api,
    stashId,
    slashes,
    nominees,
    indexes.activeEra,
    optNominators.unwrapOrDefault().submittedIn,
    exposures
  );
}
function _extractUnbondings(stakingInfo, progress) {
  if (!stakingInfo?.unlocking || !progress) {
    return { mapped: [], total: BN_ZERO };
  }

  const mapped = stakingInfo.unlocking
    .filter(
      ({ remainingEras, value }) =>
        value.gt(BN_ZERO) && remainingEras.gt(BN_ZERO)
    )
    .map((unlock) => [
      unlock,
      unlock.remainingEras
        .sub(BN_ONE)
        .imul(progress.eraLength)
        .iadd(progress.eraLength)
        .isub(progress.eraProgress)
        .toNumber(),
    ]);
  const total = mapped.reduce(
    (total, [{ value }]) => total.iadd(value),
    new BN(0)
  );

  return {
    mapped: mapped.map((i) => [
      formatBalance(i[0].value, { forceUnit: "-", withSi: false }),
      i[1],
    ]),
    total,
  };
}
async function getOwnStashInfo(accountId) {
  const [stashId, isOwnStash] = await _getOwnStash(accountId);
  const [account, validators, allStashes, progress] = await Promise.all([
    api.derive.staking.account(stashId),
    api.query.staking.validators(stashId),
    api.derive.staking.stashes().then((res) => res.map((i) => i.toString())),
    api.derive.session.progress(),
  ]);
  const stashInfo = _extractStakerState(accountId, stashId, allStashes, [
    isOwnStash,
    account,
    validators,
  ]);
  const unbondings = _extractUnbondings(account, progress);
  let inactives;
  if (stashInfo.nominating && stashInfo.nominating.length) {
    inactives = await _getInactives(stashId, stashInfo.nominating);
  }
  return {
    account,
    ...stashInfo,
    inactives,
    unbondings,
  };
}

async function getSlashingSpans(stashId) {
  const res = await api.query.staking.slashingSpans(stashId);
  return res.isNone ? 0 : res.unwrap().prior.length + 1;
}

export default {
  loadValidatorRewardsData,
  loadAccountRewardsData,
  fetchStakingOverview,
  getOwnStashInfo,
  getSlashingSpans,
};
