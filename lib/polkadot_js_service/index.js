const { seedGenerate, seedToMnemonic } = require("./utils/bip39Util");
const { Keyring } = require("@polkadot/keyring");
const { u8aToHex } = require("@polkadot/util");
const keyring = new Keyring({ ss58Format: 2, type: "ed25519" });

// A micro service will exit when it has nothing left to do.  So to
// avoid a premature exit, set an indefinite timer.  When we
// exit() later, the timer will get invalidated.
setInterval(() => {}, 1000);

const accountGen = msg => {
  const seed = seedGenerate();
  const key = seedToMnemonic(seed);
  const keyPair = keyring.addFromMnemonic(key);
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

LiquidCore.on("get", msg => {
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
LiquidCore.emit("ready");
