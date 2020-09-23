import "@babel/polyfill";
import { enable, handleResponse } from "@polkadot/extension-base/page";
import { injectExtension } from "@polkadot/extension-inject";
import { web3Accounts, web3Enable } from "@polkadot/extension-dapp";
import handlers from "./handlers";

// send message to JSChannel: assembly
function send(path, data) {
  if (window.location.href.match("js_as_extension")) {
    console.log(path, data);
  } else {
    Extension.postMessage(JSON.stringify({ path, data }));
  }
}
send("log", "main js loaded");
window.send = send;

// window.postMessage = (msg, source) => {
//   window.send(source, msg);
// };

// setup a response listener (events created by the loader for extension responses)
window.addEventListener("message", ({ data, source }) => {
  // only allow messages from our window, by the loader
  if (source !== window) {
    return;
  }

  if (data.origin === "content") {
    if (data.id) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      handleResponse(data);
    } else {
      console.error("Missing id for response.");
    }
  } else if (data.origin === "page") {
    handlers.handleMsg(data);
  }
});

injectExtension(enable, {
  name: "polkawallet",
  version: "0.9.0",
});

async function test() {
  // returns an array of all the injected sources
  // (this needs to be called first, before other requests)
  const allInjected = await web3Enable("my cool dapp");
  send("log", allInjected);

  // returns an array of { address, meta: { name, source } }
  // meta.source contains the name of the extension that provides this account
  const allAccounts = await web3Accounts();
  send("log", allAccounts);
}

window.walletExtension = {
  test,
  onAppResponse: handlers.onAppResponse,
};
