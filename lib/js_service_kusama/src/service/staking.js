import BN from "bn.js";

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

async function getSlashingSpans(stashId) {
  const res = await api.query.staking.slashingSpans(stashId);
  return res.isNone ? 0 : res.unwrap().prior.length + 1;
}

export default {
  loadValidatorRewardsData,
  loadAccountRewardsData,
  fetchStakingOverview,
  getSlashingSpans,
};
