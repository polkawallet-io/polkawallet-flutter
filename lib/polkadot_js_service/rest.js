const Koa = require("koa");
const app = new Koa();

const { mnemonicGenerate } = require("./utils/bip39Util");
const { Keyring } = require("@polkadot/keyring");
const keyring = new Keyring({ ss58Format: 2, type: "ed25519" });

const accountGen = () => {
  const key = mnemonicGenerate();
  const keyPair = keyring.addFromMnemonic(key);
  const res = {
    address: keyPair.address,
    meta: keyPair.meta,
    isLocked: keyPair.isLocked,
    publicKey: keyPair.publicKey,
    type: keyPair.type,
    mnemonic: key
  };
  return JSON.stringify(res);
};

const routes = {
  "/account/gen": accountGen
};

app.use(ctx => {
  const route = routes[ctx.request.path];
  if (route) {
    ctx.body = route();
  } else {
    ctx.body = `${ctx.request.path} : 404`;
  }
});

app.listen(3000);
