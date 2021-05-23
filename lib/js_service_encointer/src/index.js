import '@babel/polyfill';
import account from './service/account';
import encointer from './service/encointer';
import settings from './service/settings';
import chain from './service/chain';

// send message to JSChannel: PolkaWallet
function send (path, data) {
  if (window.location.href === 'about:blank') {
    PolkaWallet.postMessage(JSON.stringify({ path, data }));
  } else {
    console.log(path, data);
  }
}
window.send = send;

console.log('This is new!');

window.settings = settings;
window.account = account;
window.encointer = encointer;
window.chain = chain;
