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

const msgChannelSyntheticPools = "LaminarSyntheticPools";
async function subscribeSyntheticPools() {
  laminarApi.synthetic.allPoolIds().subscribe((ids) => {
    ids.forEach((id) => {
      laminarApi.synthetic.poolInfo(id).subscribe((res) => {
        res.options.forEach((e) => (e.poolId = res.poolId));
        send(msgChannelSyntheticPools, res);
      });
    });
  });
  return {};
}

const msgChannelMarginPools = "LaminarMarginPools";
async function subscribeMarginPools() {
  laminarApi.margin.allPoolIds().subscribe((ids) => {
    ids.forEach((id) => {
      laminarApi.margin.poolInfo(id).subscribe((res) => {
        res.options.forEach((e) => (e.poolId = res.poolId));
        send(msgChannelMarginPools, res);
      });
    });
  });
  return {};
}
const msgChannelMarginTraderInfo = "LaminarMarginTraderInfo";
async function subscribeMarginTraderInfo(address) {
  laminarApi.margin.allPoolIds().subscribe((ids) => {
    ids.forEach((id) => {
      laminarApi.margin.traderInfo(address, id).subscribe((res) => {
        res.poolId = id;
        send(msgChannelMarginTraderInfo, res);
      });
    });
  });
  return {};
}

export default {
  subscribeMessage,
  getTokens,
  subscribeSyntheticPools,
  subscribeMarginPools,
  subscribeMarginTraderInfo,
};
