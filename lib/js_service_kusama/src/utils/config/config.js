import linked from "./links/index";

function _shortName(name) {
  return `${name[0]}${name[name.length - 1]}`;
}

export async function genLinks({ data, hash, type, withShort }) {
  const systemChain = await api.rpc.system.chain();
  return Object.entries(linked).map(
    ([name, { chains, create, isActive, paths, url }]) => {
      const extChain = chains[systemChain.toHuman()];
      const extPath = paths[type];

      if (!isActive || !extChain || !extPath) {
        return null;
      }

      return {
        name: withShort ? _shortName(name) : name,
        link: create(extChain, extPath, data, hash),
      };
    }
  );
}
