import '@babel/polyfill';
import { ApiPromise } from '@polkadot/api';
import { WsProvider } from '@polkadot/rpc-provider';
import account from './service/account';
import encointer from './service/encointer';
import worker from './service/worker';
import { CustomTypes } from './config/types';

// send message to JSChannel: PolkaWallet
function send (path, data) {
  if (window.location.href === 'about:blank') {
    PolkaWallet.postMessage(JSON.stringify({ path, data }));
  } else {
    console.log(path, data);
  }
}
window.send = send;

async function connect (endpoint) {
  return new Promise(async (resolve, reject) => {
    const provider = new WsProvider(endpoint);
    try {
      window.api = await ApiPromise.create({
        provider,
        types: CustomTypes
      });
      send('log', `${endpoint} wss connected success`);
      resolve(endpoint);
    } catch (err) {
      send('log', `connect ${endpoint} failed`);
      provider.disconnect();
      resolve(null);
    }
  });
}

async function connectAll (nodes) {
  let failCount = 0;
  return new Promise((resolve, reject) => {
    nodes.forEach(async (endpoint) => {
      const provider = new WsProvider(endpoint);
      try {
        const api = await ApiPromise.create({
          provider,
          types: CustomTypes
        });
        if (!window.api) {
          window.api = api;
          send('log', `${endpoint} wss connected success`);
          resolve(endpoint);
        } else {
          send('log', `${endpoint} wss connected and ignored`);
          api.disconnect();
        }
      } catch (err) {
        send('log', `connect ${endpoint} failed`);
        provider.disconnect();
        failCount += 1;
        if (failCount >= nodes.length) {
          resolve(null);
        }
      }
    });
  });
}

// untested
async function setWorkerEndpoint (endpoint) {
  return new Promise((resolve, reject) => {
    window.workerEndpoint = endpoint;
    send('log', `set worker endpoint ${endpoint}`);
    resolve(endpoint);
  });
}

const test = async (address) => {
  // const props = await api.rpc.system.properties();
  // send('log', props);
};

async function getNetworkConst () {
  return api.consts;
}

function changeEndpoint (endpoint) {
  try {
    send('log', 'disconnect');
    window.api.disconnect();
  } catch (err) {
    send('log', err.message);
  }
  return connect(endpoint);
}

async function subscribeMessage (section, method, params, msgChannel) {
  return api.derive[section][method](...params, (res) => {
    send(msgChannel, res);
  }).then((unsub) => {
    const unsubFuncName = `unsub${msgChannel}`;
    window[unsubFuncName] = unsub;
    return {};
  });
}

async function isConnected () {
  return api.isConnected;
}

window.settings = {
  test,
  connect,
  connectAll,
  setWorkerEndpoint,
  isConnected,
  getNetworkConst,
  changeEndpoint,
  subscribeMessage
};

window.account = account;
window.encointer = encointer;
window.worker = worker;
