import "@babel/polyfill";
import { WsProvider, ApiPromise } from "@polkadot/api";
import { options } from "@acala-network/api";
import account from "./service/account";
import acala from "./service/acala";
import { genLinks } from "./utils/config/config";

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
    const provider = new WsProvider(endpoint);
    try {
      const res = new ApiPromise(options({ provider }));
      await res.isReady;
      window.api = res;
      send("log", `${endpoint} wss connected success`);
      resolve(endpoint);
    } catch (err) {
      send("log", `connect ${endpoint} failed`);
      provider.disconnect();
      resolve(null);
    }
  });
}

async function connectAll(nodes) {
  let failCount = 0;
  return new Promise((resolve, reject) => {
    nodes.forEach(async (endpoint) => {
      const provider = new WsProvider(endpoint);
      try {
        const res = new ApiPromise(options({ provider }));
        await res.isReady;
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
        provider.disconnect();
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
  return {
    currencyIds: api.registry.createType("CurrencyId").defKeys,
    ...api.consts,
  };
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
  return chainProperties;
}

window.settings = {
  test,
  connect,
  connectAll,
  getNetworkConst,
  getNetworkPropoerties,
  subscribeMessage,
  genLinks,
};

window.account = account;
window.acala = acala;
