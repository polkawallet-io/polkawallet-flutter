import "@babel/polyfill";
import { ApiPromise } from "@polkadot/api";
import { WsProvider } from "@polkadot/rpc-provider";
import { options } from "@acala-network/api";
import account from "./service/account";
import acala from "./service/acala";

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
  try {
    const provider = new WsProvider(endpoint);
    window.api = new ApiPromise(options({ provider }));
    await api.isReady;
    return "wss connect success";
  } catch (err) {
    send("log", err.message);
    return null;
  }
  // return new Promise((resolve, reject) => {
  //   return ApiPromise.create({ provider: new WsProvider(endpoint), types })
  //     .then(api => {
  //       window.api = api;
  //       resolve("wss connect success");
  //     })
  //     .catch(err => {
  //       send("log", err.message);
  //       resolve(null);
  //     });
  // });
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

window.settings = {
  test,
  connect,
  getNetworkConst,
  subscribeMessage,
};

window.account = account;
window.acala = acala;
