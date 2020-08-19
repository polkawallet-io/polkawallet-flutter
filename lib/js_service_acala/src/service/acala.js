import { formatBalance } from "@polkadot/util";
import {
  Fixed18,
  convertToFixed18,
  calcSupplyInBaseToOther,
  calcSupplyInOtherToBase,
  calcSupplyInOtherToOther,
  calcTargetInBaseToOther,
  calcTargetInOtherToBase,
  calcTargetInOtherToOther,
  StakingPoolHelper,
} from "@acala-network/app-util";
import BN from "bn.js";

const divisor = new BN("1".padEnd(18 + 1, "0"));

function balanceToNumber(amount) {
  return (
    amount
      .muln(1000)
      .div(divisor)
      .toNumber() / 1000
  );
}

/**
 * get token balances of an address
 * @param {String} address
 * @param {String} currencyId
 * @returns {String} balance
 */
async function getTokens(address, currencyId) {
  const res = await api.query.tokens.accounts(address, currencyId);
  return formatBalance(res.free, { forceUnit: "-", withSi: false });
}

/**
 * calc token swap amount
 * @param {Api} api
 * @param {Number} supply
 * @param {Number} target
 * @param {List<String>} swapPair
 * @param {Number} baseCoin
 * @param {Number} slippage
 * @returns {String} output
 */
async function calcTokenSwapAmount(
  api,
  supply,
  target,
  swapPair,
  baseCoin,
  slippage
) {
  const pool = await Promise.all([
    api.derive.dex.pool(swapPair[0]),
    api.derive.dex.pool(swapPair[1]),
  ]);
  const feeRate = api.consts.dex.getExchangeFee;
  let output;
  if (target == null) {
    if (baseCoin == 0) {
      output = calcTargetInBaseToOther(
        Fixed18.fromNatural(supply),
        _dexPoolToFixed18(pool[1]),
        convertToFixed18(feeRate),
        Fixed18.fromNatural(slippage)
      );
    } else if (baseCoin == 1) {
      output = calcTargetInOtherToBase(
        Fixed18.fromNatural(supply),
        _dexPoolToFixed18(pool[0]),
        convertToFixed18(feeRate),
        Fixed18.fromNatural(slippage)
      );
    } else {
      output = calcTargetInOtherToOther(
        Fixed18.fromNatural(supply),
        _dexPoolToFixed18(pool[0]),
        _dexPoolToFixed18(pool[1]),
        convertToFixed18(feeRate),
        Fixed18.fromNatural(slippage)
      );
    }
  } else if (supply == null) {
    if (baseCoin == 0) {
      output = calcSupplyInBaseToOther(
        Fixed18.fromNatural(target),
        _dexPoolToFixed18(pool[1]),
        convertToFixed18(feeRate),
        Fixed18.fromNatural(slippage)
      );
    } else if (baseCoin == 1) {
      output = calcSupplyInOtherToBase(
        Fixed18.fromNatural(target),
        _dexPoolToFixed18(pool[0]),
        convertToFixed18(feeRate),
        Fixed18.fromNatural(slippage)
      );
    } else {
      output = calcSupplyInOtherToOther(
        Fixed18.fromNatural(target),
        _dexPoolToFixed18(pool[0]),
        _dexPoolToFixed18(pool[1]),
        convertToFixed18(feeRate),
        Fixed18.fromNatural(slippage)
      );
    }
  }
  return output.toString();
}

function _dexPoolToFixed18(pool) {
  return {
    base: convertToFixed18(pool.base),
    other: convertToFixed18(pool.other),
  };
}

/**
 * fetchDexPoolInfo
 * @param {String} currencyId
 * @param {String} address
 * @returns {Map} dexPoolInfo
 */
async function fetchDexPoolInfo(currencyId, address) {
  const pool = await Promise.all([
    api.query.dex.liquidityPool(currencyId),
    api.query.dex.totalShares(currencyId),
    api.query.dex.shares(currencyId, address),
    api.query.dex.totalInterest(currencyId),
    api.query.dex.withdrawnInterest(currencyId, address),
  ]);
  let proportion = 0;
  if (pool[1]) {
    proportion = balanceToNumber(pool[2]) / balanceToNumber(pool[1]);
  }
  const reward =
    balanceToNumber(pool[3][0]) * proportion - balanceToNumber(pool[4]);
  return {
    token: currencyId,
    pool: pool[0],
    sharesTotal: pool[1],
    shares: pool[2],
    proportion: proportion || 0,
    reward: reward || 0,
  };
}

async function _getStakingPoolHelper(api, stakingPool) {
  return new StakingPoolHelper({
    totalBonded: stakingPool.totalBonded,
    communalFree: stakingPool.freeUnbonded,
    unbondingToFree: stakingPool.unbondingToFree,
    nextEraClaimedUnbonded: stakingPool.nextEraUnbond[1],
    liquidTokenIssuance: stakingPool.liquidTokenIssuance,
    defaultExchangeRate: stakingPool.defaultExchangeRate,
    maxClaimFee: stakingPool.maxClaimFee,
    bondingDuration: stakingPool.bondingDuration,
    currentEra: stakingPool.currentEra,
  });
}

async function fetchLDOTPrice(api) {
  const stakingPool = await api.derive.homa.stakingPool();
  const stakingPoolHelper = await _getStakingPoolHelper(api, stakingPool);
  const priceDot = await api.derive.price.price("DOT");
  return (
    balanceToNumber(priceDot.value ? priceDot.value.value : new BN(0)) *
    stakingPoolHelper.liquidExchangeRate.toNumber()
  );
}

async function _calacFreeList(helper, start, duration) {
  const list = [];
  for (let i = start; i < start + duration; i++) {
    const result = await api.query.stakingPool.unbonding(i);
    const free = Fixed18.fromParts(result[0].toString()).sub(
      Fixed18.fromParts(result[1].toString())
    );
    list.push({
      era: i,
      free: free.toNumber(18, 3),
    });
  }
  return list
    .filter((item) => item.free)
    .map((i) => {
      return {
        ...i,
        claimFeeRatio: helper.claimFeeRatio(i.era).toNumber(18, 3),
      };
    });
}

async function fetchHomaStakingPool(api) {
  const [stakingPool, priceDot, rewardRate] = await Promise.all([
    api.derive.homa.stakingPool(),
    api.derive.price.price("DOT"),
    api.query.polkadotBridge.mockRewardRate(),
  ]);
  const stakingPoolHelper = await _getStakingPoolHelper(api, stakingPool);
  const priceLDOT =
    balanceToNumber(priceDot.value ? priceDot.value.value : new BN(0)) *
    stakingPoolHelper.liquidExchangeRate.toNumber();
  const freeList = await _calacFreeList(
    stakingPoolHelper,
    stakingPool.currentEra.toNumber() + 1,
    stakingPool.bondingDuration.toNumber()
  );
  const eraLength = api.consts.polkadotBridge.eraLength;
  const expectedBlockTime = api.consts.babe.expectedBlockTime;
  const unbondingDuration =
    expectedBlockTime.toNumber() *
    Number(eraLength.toString()) *
    stakingPool.bondingDuration.toNumber();
  return {
    // ...stakingPoolHelper,
    rewardRate: rewardRate.toString(),
    priceLDOT,
    freeList,
    claimFeeRatio: stakingPoolHelper
      .claimFeeRatio(stakingPool.currentEra.toNumber())
      .toNumber(18, 3),
    unbondingDuration,
    totalBonded: stakingPoolHelper.totalBonded.toNumber(18, 3),
    communalFree: stakingPoolHelper.communalFree.toNumber(18, 3),
    unbondingToFree: stakingPoolHelper.unbondingToFree.toNumber(18, 3),
    nextEraClaimedUnbonded: stakingPoolHelper.nextEraClaimedUnbonded.toNumber(
      18,
      3
    ),
    liquidTokenIssuance: stakingPoolHelper.liquidTokenIssuance.toNumber(18, 3),
    defaultExchangeRate: stakingPoolHelper.defaultExchangeRate.toNumber(18, 3),
    maxClaimFee: stakingPoolHelper.maxClaimFee.toNumber(18, 3),
    bondingDuration: stakingPoolHelper.bondingDuration,
    currentEra: stakingPoolHelper.currentEra,
    communalBonded: stakingPoolHelper.communalBonded.toNumber(18, 3),
    communalTotal: stakingPoolHelper.communalTotal.toNumber(18, 3),
    communalBondedRatio: stakingPoolHelper.communalBondedRatio.toNumber(18, 3),
    liquidExchangeRate: stakingPoolHelper.liquidExchangeRate.toNumber(18, 3),
  };
}

async function fetchHomaUserInfo(api, address) {
  const stakingPool = await api.derive.homa.stakingPool();
  const start = stakingPool.currentEra.toNumber() + 1;
  const duration = stakingPool.bondingDuration.toNumber();
  const claims = [];
  for (let i = start; i < start + duration + 2; i++) {
    const claimed = await api.query.stakingPool.claimedUnbond(address, i);
    if (claimed.gtn(0)) {
      claims[claims.length] = {
        era: i,
        claimed,
      };
    }
  }
  const unbonded = await api.rpc.stakingPool.getAvailableUnbonded(address);
  return {
    unbonded: unbonded.amount || 0,
    claims,
  };
}

export default {
  getTokens,
  calcTokenSwapAmount,
  fetchDexPoolInfo,
  fetchLDOTPrice,
  fetchHomaStakingPool,
  fetchHomaUserInfo,
};
