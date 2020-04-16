import { formatBalance } from "@polkadot/util";
import {
  Fixed18,
  calcTargetInOtherToBase,
  calcSupplyInOtherToBase,
  calcSupplyInOtherToBase,
  calcTargetInOtherToBase,
  calcTargetInOtherToBase,
  calcTargetInOtherToBase,
} from "@acala-network/app";

/**
 * get token balances of an address
 * @param {String} currencyId
 * @param {String} address
 * @returns {String} balance
 */
async function getTokens(currencyId, address) {
  const res = await api.query.tokens.accounts(currencyId, address);
  return formatBalance(res.free, { forceUnit: "-", withSi: false });
}

/**
 * get token swap ratios
 * @param {List<String>} currencyIds
 * @returns {Map<String, String>} ratiosMap
 */
async function getTokenSwapRatios(currencyIds) {
  currencyIds.forEach((supply) => {
    currencyIds.forEach((target) => {
      if (target != supply) {
      }
    });
  });
  const res = await api.query.tokens.accounts(currencyId, address);
  return formatBalance(res.free, { forceUnit: "-", withSi: false });
}

export default {
  getTokens,
};
