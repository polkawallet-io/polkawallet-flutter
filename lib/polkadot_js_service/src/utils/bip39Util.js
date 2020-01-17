import { entropyToMnemonic } from "bip39";
import crypto from "crypto-browserify";

const STRENGTH_MAP = {
  12: 16 * 8,
  15: 20 * 8,
  18: 24 * 8,
  21: 28 * 8,
  24: 32 * 8
};

const seedGenerate = (words = 12) => {
  const strength = STRENGTH_MAP[words];
  return crypto.randomBytes(strength / 8);
};

const seedToMnemonic = seed => {
  return entropyToMnemonic(seed);
};

const mnemonicGenerate = (words = 12) => {
  const strength = STRENGTH_MAP[words];
  const entropy = crypto.randomBytes(strength / 8);
  return entropyToMnemonic(entropy);
};

export { mnemonicGenerate, seedGenerate, seedToMnemonic };
