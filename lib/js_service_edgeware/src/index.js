import "@babel/polyfill";
import { WsProvider, ApiPromise } from "@polkadot/api";
import account from "./service/account";
import staking from "./service/staking";
import gov from "./service/gov";
import claim from "./service/claim";
import { genLinks } from "./utils/config/config";
import { POLKADOT_GENESIS } from "./constants/networkSpect";

// send message to JSChannel: PolkaWallet
function send(path, data) {
  if (window.location.href === "about:blank") {
    PolkaWallet.postMessage(JSON.stringify({ path, data }));
  } else {
    console.log(path, data);
  }
}
send("log", "main js loaded");
window.send = send;

async function connect(endpoint) {
  return new Promise(async (resolve, reject) => {
    const wsProvider = new WsProvider(endpoint);
    try {
      const res = await ApiPromise.create({
        provider: wsProvider,
      });
      window.api = res;
      send("log", `${endpoint} wss connected success`);
      resolve(endpoint);
    } catch (err) {
      send("log", `connect ${endpoint} failed`);
      wsProvider.disconnect();
      resolve(null);
    }
  });
}

async function connectAll(nodes) {
  let failCount = 0;
  return new Promise((resolve, reject) => {
    nodes.forEach(async (endpoint) => {
      const wsProvider = new WsProvider(endpoint);
      try {
        const res = await ApiPromise.create({
          provider: wsProvider,
        });
        if (!window.api) {
          window.api = res;
          send("log", `${endpoint} wss connected success`);
          resolve(endpoint);
        } else {
          send("log", `${endpoint} wss connected and ignored`);
          res.disconnect();
        }
      } catch (err) {
        send("log", `connect ${endpoint} failed`);
        wsProvider.disconnect();
        failCount += 1;
        if (failCount >= nodes.length) {
          resolve(null);
        }
      }
    });
  });
}

const test = async (address) => {
  // const props = await api.rpc.system.properties();
  // send("log", props);
};

async function getNetworkConst() {
  return api.consts;
}

function changeEndpoint(endpoint) {
  try {
    send("log", "disconnect");
    window.api.disconnect();
  } catch (err) {
    send("log", err.message);
  }
  return connect(endpoint);
}

async function subscribeMessage(section, method, params, msgChannel) {
  return api.derive[section][method](...params, (res) => {
    send(msgChannel, res);
  }).then((unsub) => {
    const unsubFuncName = `unsub${msgChannel}`;
    window[unsubFuncName] = unsub;
    return {};
  });
}

async function getNetworkPropoerties() {
  const chainProperties = await api.rpc.system.properties();
  return api.genesisHash.toHuman() == POLKADOT_GENESIS
    ? api.registry.createType("ChainProperties", {
        ...chainProperties,
        tokenDecimals: 10,
        tokenSymbol: "DOT",
      })
    : chainProperties;
}

window.settings = {
  test,
  connect,
  connectAll,
  getNetworkConst,
  getNetworkPropoerties,
  changeEndpoint,
  subscribeMessage,
  genLinks,
};

window.account = account;
window.staking = staking;
window.gov = gov;
window.claim = claim;
