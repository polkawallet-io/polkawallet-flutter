import { formatBalance } from "@polkadot/util";
import { Fixed18, StakingPoolHelper } from "@acala-network/app-util";
import { FixedPointNumber, getPresetToken } from "@acala-network/sdk-core";
import { SwapTrade } from "@acala-network/sdk-swap";

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
 * @param {Number} input
 * @param {Number} output
 * @param {List<String>} swapPair
 * @param {Number} slippage
 * @returns {String} output
 */
async function calcTokenSwapAmount(api, input, output, swapPair, slippage) {
  const i = getPresetToken(swapPair[0]).clone({
    amount: new FixedPointNumber(input || 0),
  });
  const o = getPresetToken(swapPair[1]).clone({
    amount: new FixedPointNumber(output || 0),
  });
  const mode = output === null ? "EXACT_INPUT" : "EXACT_OUTPUT";
  const availableTokenPairs = SwapTrade.getAvailableTokenPairs(api);
  const maxTradePathLength = new FixedPointNumber(api.consts.dex.tradingPathLimit.toString());
  const fee = {
    numerator: new FixedPointNumber(api.consts.dex.getExchangeFee[0].toString()),
    denominator: new FixedPointNumber(api.consts.dex.getExchangeFee[1].toString()),
  };
  const swapTrader = new SwapTrade({
    input: i,
    output: o,
    mode,
    availableTokenPairs,
    maxTradePathLength,
    fee,
    acceptSlippage: new FixedPointNumber(slippage),
  });

  const paths = swapTrader.getTradeTokenPairsByPaths();
  const res = await api.queryMulti(
    paths.map((e) => [api.query.dex.liquidityPool, e.toChainData()])
  );
  const pools = SwapTrade.convertLiquidityPoolsToTokenPairs(paths, res);
  const data = swapTrader.getTradeParameters(pools);
  const params = data.toChainData(mode);
  return {
    amount: output === null ? data.output.amount.toNumber(6) : data.input.amount.toNumber(6),
    path: params[0],
    input: params[1],
    output: params[2],
  };
}

async function queryLPTokens(address) {
  const allTokens = api.consts.dex.enabledTradingPairs.map((item) =>
    api.createType("CurrencyId", {
      DEXShare: [item[0].asToken.toString(), item[1].asToken.toString()],
    })
  );

  const res = await api.queryMulti(allTokens.map((e) => [api.query.tokens.accounts, [address, e]]));
  return res
    .map((e, i) => ({ free: e.free.toString(), currencyId: allTokens[i].asDexShare }))
    .filter((e) => e.free > 0);
}

/**
 * getTokenPairs
 * @param {String} currencyId
 * @param {String} address
 * @returns {Map} dexPoolInfo
 */
async function getTokenPairs() {
  return SwapTrade.getAvailableTokenPairs(api).map((e) => e.origin);
}

/**
 * fetchDexPoolInfo
 * @param {String} poolId
 * @param {String} address
 * @returns {Map} dexPoolInfo
 */
async function fetchDexPoolInfo(pool, address) {
  const res = await Promise.all([
    api.query.dex.liquidityPool(pool.DEXShare.map((e) => ({ Token: e }))),
    api.query.rewards.pools({ DexIncentive: pool }),
    api.query.rewards.pools({ DexSaving: pool }),
    api.query.rewards.shareAndWithdrawnReward({ DexIncentive: pool }, address),
    api.query.rewards.shareAndWithdrawnReward({ DexSaving: pool }, address),
    api.query.tokens.totalIssuance(pool),
  ]);
  let proportion = 0;
  if (res[2]) {
    proportion = FixedPointNumber.fromInner(res[3][0].toString())
      .div(FixedPointNumber.fromInner(res[1].totalShares.toString()))
      .toNumber();
  }
  return {
    token: pool.DEXShare.join("-"),
    pool: res[0],
    sharesTotal: res[1].totalShares,
    shares: res[3][0],
    proportion: proportion || 0,
    reward: {
      incentive: new FixedPointNumber(res[1].totalRewards * proportion - res[3][1] || 0).toString(),
      saving: new FixedPointNumber(res[2].totalRewards * proportion - res[4][1] || 0).toString(),
    },
    issuance: res[5],
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
  const [stakingPool, rewardRate] = await Promise.all([
    api.derive.homa.stakingPool(),
    api.query.polkadotBridge.mockRewardRate(),
  ]);
  const stakingPoolHelper = await _getStakingPoolHelper(api, stakingPool);
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
    freeList,
    claimFeeRatio: stakingPoolHelper
      .claimFeeRatio(stakingPool.currentEra.toNumber())
      .toNumber(18, 3),
    unbondingDuration,
    totalBonded: stakingPoolHelper.totalBonded.toNumber(18, 3),
    communalFree: stakingPoolHelper.communalFree.toNumber(18, 3),
    unbondingToFree: stakingPoolHelper.unbondingToFree.toNumber(18, 3),
    nextEraClaimedUnbonded: stakingPoolHelper.nextEraClaimedUnbonded.toNumber(18, 3),
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
  queryLPTokens,
  getTokenPairs,
  fetchDexPoolInfo,
  fetchHomaStakingPool,
  fetchHomaUserInfo,
};
