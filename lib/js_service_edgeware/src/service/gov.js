import { GenericCall, getTypeDef } from "@polkadot/types";

import registry from "../utils/registry";

function _extractMetaData(value) {
  const params = GenericCall.filterOrigin(value).map(({ name, type }) => ({
    name: name.toString(),
    type: getTypeDef(type.toString()),
  }));
  const values = value.args.map((value) => ({
    isValid: true,
    value,
  }));
  const hash = value.hash;
  return { hash, params, values };
}

async function fetchReferendums() {
  const referendums = await api.derive.democracy.referendums();
  const details = referendums.map(({ image }) => {
    if (!image.proposal) {
      return {};
    }
    const callData = registry.findMetaCall(image.proposal.callIndex);
    const parsedMeta = _extractMetaData(callData.meta);
    image.proposal = image.proposal.toHuman();
    return {
      title: `${callData.section}.${callData.method}`,
      content: callData.meta?.documentation.join(" "),
      ...parsedMeta,
    };
  });
  return { referendums, details };
}

async function fetchCouncilVotes() {
  const councilVotes = await api.derive.council.votes();
  return councilVotes.reduce((result, [voter, { stake, votes }]) => {
    votes.forEach((candidate) => {
      const address = candidate.toString();
      if (!result[address]) {
        result[address] = {};
      }
      result[address][voter] = stake;
    });
    return result;
  }, {});
}

export default {
  fetchReferendums,
  fetchCouncilVotes,
};
