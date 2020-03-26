import "@babel/polyfill";
import { WsProvider, ApiPromise } from "@polkadot/api";
import { types } from "@acala-network/types";
import account from "./service/account";

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
    return ApiPromise.create({ provider: new WsProvider(endpoint), types })
      .then(api => {
        window.api = api;
        resolve("wss connect success");
      })
      .catch(err => {
        send("log", err.message);
        resolve(null);
      });
  });
}

const test = async address => {
  // const props = await api.rpc.system.properties();
  // send("log", props);
};

async function getNetworkConst() {
  return api.consts;
}

window.settings = {
  test,
  connect,
  getNetworkConst
};

window.account = account;
