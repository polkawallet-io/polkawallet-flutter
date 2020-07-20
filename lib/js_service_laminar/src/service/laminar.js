import { formatBalance } from "@polkadot/util";

async function subscribeMessage(section, method, params, msgChannel) {
  const s = laminarApi[section][method](...params).subscribe((res) => {
    send(msgChannel, res);
  });
  const unsubFuncName = `unsub${msgChannel}`;
  window[unsubFuncName] = s.unsubscribe;
  return {};
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

export default {
  subscribeMessage,
  getTokens,
};
