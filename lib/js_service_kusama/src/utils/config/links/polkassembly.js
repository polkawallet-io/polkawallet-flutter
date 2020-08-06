export default {
  chains: {
    Kusama: "kusama",
    "Kusama CC3": "kusama",
    Polkadot: "polkadot",
  },
  create: (chain, path, data) =>
    `https://${chain}.polkassembly.io/${path}/${data.toString()}`,
  isActive: true,
  paths: {
    council: "motion",
    proposal: "proposal",
    referendum: "referendum",
    treasury: "treasury",
  },
  url: "https://polkassembly.io/",
};
