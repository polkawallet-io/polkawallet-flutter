import 'core-js/stable/index.js';
import 'regenerator-runtime/runtime.js';

import account from './service/account.js';
import encointer from './service/encointer.js';
import settings from './service/settings.js';
import chain from './service/chain.js';

// send message to JSChannel: PolkaWallet
function send (path, data) {
  if (window.location.href === 'about:blank') {
    PolkaWallet.postMessage(JSON.stringify({
      path,
      data
    }));
  } else {
    console.log(path, data);
  }
}

window.send = send;

window.settings = settings;
window.account = account;
window.encointer = encointer;
window.chain = chain;

console.log('Initialized Window');
