import { formatBalance } from "@polkadot/util";

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

export default {
  getTokens
};
