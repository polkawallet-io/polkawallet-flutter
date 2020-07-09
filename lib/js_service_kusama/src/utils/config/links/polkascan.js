export default {
  chains: {
    // 'Centrifuge Mainnet': 'centrifuge',
    // Edgeware: 'edgeware',
    // Kulupu: 'kulupu',
    Kusama: "kusama",
    "Polkadot CC1": "polkadot-cc1",
  },
  create: (chain, path, data) =>
    `https://polkascan.io/${chain}/${path}/${data.toString()}`,
  isActive: true,
  paths: {
    address: "account",
    block: "block",
    council: "council/motion",
    extrinsic: "transaction",
    proposal: "democracy/proposal",
    referendum: "democracy/referendum",
    techcomm: "techcomm/proposal",
    treasury: "treasury/proposal",
  },
  url: "https://polkascan.io/",
};
