require("babel-polyfill");
const { seedGenerate, seedToMnemonic } = require("./utils/bip39Util");
const { Keyring } = require("@polkadot/keyring");
const { u8aToHex } = require("@polkadot/util");
const keyring = new Keyring({ ss58Format: 2, type: "ed25519" });

const { ApiPromise, WsProvider } = require("@polkadot/api");

// A micro service will exit when it has nothing left to do.  So to
// avoid a premature exit, set an indefinite timer.  When we
// exit() later, the timer will get invalidated.
setInterval(() => {}, 1000);

async function connect() {
  try {
    // Initialise the provider to connect to the kusama node
    const provider = new WsProvider("wss://kusama-rpc.polkadot.io/");
    LiquidCore.emit("ready", { data: "ws ready" });
    // Create the API and wait until ready
    const api = await ApiPromise.create({ provider });
    LiquidCore.emit("ready", { data: "api ready" });
  } catch (err) {
    LiquidCore.emit("ready", { data: err });
  }

  // // Retrieve the chain & node information information via rpc calls
  // const [chain, nodeName, nodeVersion] = await Promise.all([
  //   api.rpc.system.chain(),
  //   api.rpc.system.name(),
  //   api.rpc.system.version()
  // ]).catch(err => {
  //   LiquidCore.emit("ready", { data: err });
  // });

  // console.log(
  //   `You are connected to chain ${chain} using ${nodeName} v${nodeVersion}`
  // );
  // LiquidCore.emit("ready", {
  //   data: `Connected to chain ${chain} using ${nodeName} v${nodeVersion}`
  // });
}

const accountGen = msg => {
  const seed = seedGenerate();
  const key = seedToMnemonic(seed);
  const keyPair = keyring.addFromMnemonic(key);
  // keyPair.setMeta({ name: msg.req.name });
  // const json = keyPair.toJson(msg.req.password);
  // json.meta.name = keyPair.meta.name;
  // json.meta.seed = u8aToHex(seed);
  // json.meta.mnemonic = key;
  const data = {
    seed: u8aToHex(seed),
    address: keyPair.address,
    // meta: keyPair.meta,
    isLocked: keyPair.isLocked,
    // publicKey: keyPair.publicKey,
    // type: keyPair.type,
    mnemonic: key
  };
  return { ...msg, data };
};

// Listen for a request from the host for the 'ping' event
LiquidCore.on("ping", msg => {
  // When we get the ping from the host, respond with "Hello, World!"
  // and then exit.
  LiquidCore.emit("pong", { message: "hello" });
  //    process.exit(0)
});

const routes = {
  "/account/gen": accountGen
};

LiquidCore.on("msg", msg => {
  const route = routes[msg.path];
  if (route) {
    const res = route(msg);
    LiquidCore.emit("res", res);
  } else {
    const res = { ...msg, data: `${msg.path} : 404` };
    LiquidCore.emit("res", res);
  }
});

// Ok, we are all set up.  Let the host know we are ready to talk
LiquidCore.emit("ready", { data: "js service ready" });
// Connect Api
try {
  connect().catch(err => {
    LiquidCore.emit("ready", { data: err });
  });
} catch (e) {
  LiquidCore.emit("ready", { data: "connect err" });
}
