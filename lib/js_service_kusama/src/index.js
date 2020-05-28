import "@babel/polyfill";
import { WsProvider, ApiPromise } from "@polkadot/api";
import account from "./service/account";
import staking from "./service/staking";
import gov from "./service/gov";
import claim from "./service/claim";
import registry from "./utils/registry";

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

function connect(endpoint) {
  return new Promise((resolve, reject) => {
    return ApiPromise.create({ provider: new WsProvider(endpoint), registry })
      .then((api) => {
        window.api = api;
        // api.rpc.system.properties().then(res => {
        //   const prop = res.toJSON();
        //   send("log", `setSS58Format ${prop.ss58Format}`);
        //   resetSS58Format(prop.ss58Format);
        // });
        resolve("wss connect success");
      })
      .catch((err) => {
        send("log", err.message);
        resolve(null);
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

window.settings = {
  test,
  connect,
  getNetworkConst,
  changeEndpoint,
  subscribeMessage,
};

window.account = account;
window.staking = staking;
window.gov = gov;
window.claim = claim;
