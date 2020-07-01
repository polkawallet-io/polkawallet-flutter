import secp256k1 from "secp256k1/elliptic";
import {
  assert,
  hexToU8a,
  stringToU8a,
  u8aToBuffer,
  u8aToString,
  u8aToHex,
  u8aConcat,
} from "@polkadot/util";
import { keccakAsHex, keccakAsU8a, decodeAddress } from "@polkadot/util-crypto";

function hashMessage(message) {
  const expanded = stringToU8a(
    `\x19Ethereum Signed Message:\n${message.length.toString()}${message}`
  );
  const hashed = keccakAsU8a(expanded);

  return u8aToBuffer(hashed);
}

function publicToAddr(publicKey) {
  return addrToChecksum(`0x${keccakAsHex(publicKey).slice(-40)}`);
}

function addrToChecksum(_address) {
  const address = _address.toLowerCase();
  const hash = keccakAsHex(address.substr(2)).substr(2);
  let result = "0x";

  for (let n = 0; n < 40; n++) {
    result = `${result}${
      parseInt(hash[n], 16) > 7 ? address[n + 2].toUpperCase() : address[n + 2]
    }`;
  }

  return result;
}

function recoverAddress(message, { recovery, signature }) {
  const msgHash = hashMessage(message);
  const senderPubKey = secp256k1.recover(msgHash, signature, recovery);

  return publicToAddr(secp256k1.publicKeyConvert(senderPubKey, false).slice(1));
}
function sigToParts(_signature) {
  const signature = hexToU8a(_signature);

  assert(
    signature.length === 65,
    `Invalid signature length, expected 65 found ${signature.length}`
  );

  let v = signature[64];

  if (v < 27) {
    v += 27;
  }

  const recovery = v - 27;

  assert(recovery === 0 || recovery === 1, "Invalid signature v value");

  return {
    recovery,
    signature: u8aToBuffer(signature.slice(0, 64)),
  };
}

async function recoverFromJSON(signatureJson) {
  try {
    const { msg, sig } = JSON.parse(signatureJson || "{}");

    if (!msg || !sig) {
      throw new Error("Invalid signature object");
    }

    const parts = sigToParts(sig);

    return {
      error: null,
      ethereumAddress: api.registry.createType(
        "EthereumAddress",
        recoverAddress(msg, parts)
      ),
      signature: api.registry.createType(
        "EcdsaSignature",
        u8aConcat(parts.signature, new Uint8Array([parts.recovery]))
      ),
    };
  } catch (error) {
    return {
      error: error.message,
      ethereumAddress: null,
      signature: null,
    };
  }
}

async function getClaimPrefix(accountId) {
  const prefix = u8aToString(api.consts.claims.prefix.toU8a(true));
  return `${prefix}${u8aToHex(decodeAddress(accountId), -1, false)}`;
}

export default {
  addrToChecksum,
  getClaimPrefix,
  recoverFromJSON,
};
