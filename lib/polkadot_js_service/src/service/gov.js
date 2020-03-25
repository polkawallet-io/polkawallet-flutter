import BN from "bn.js";

import { GenericCall, getTypeDef } from "@polkadot/types";

import registry from "../utils/registry";

async function _getReferendumVotes(tally, index) {
  const votes = await api.derive.democracy.referendumVotes(index);

  const allAye = [];
  const allNay = [];

  votes.forEach(derived => {
    if (derived.vote.isAye) {
      allAye.push(derived);
    } else {
      allNay.push(derived);
    }
  });

  return {
    allAye,
    allNay,
    voteCount: allAye.length + allNay.length,
    voteCountAye: allAye.length,
    voteCountNay: allNay.length,
    votedAye: tally.ayes,
    votedNay: tally.nays,
    votedTotal: tally.turnout
  };
}

function _extractMetaData(value) {
  const params = GenericCall.filterOrigin(value).map(({ name, type }) => ({
    name: name.toString(),
    type: getTypeDef(type.toString())
  }));
  const values = value.args.map(value => ({
    isValid: true,
    value
  }));
  const hash = value.hash;
  return { hash, params, values };
}

async function fetchReferendums() {
  const referendums = await api.derive.democracy.referendums();
  const votes = await Promise.all(
    referendums.map(i => _getReferendumVotes(i.status.tally, i.index))
  );
  const details = referendums.map(i => {
    if (!i.proposal) {
      return {};
    }
    const callData = registry.findMetaCall(i.proposal.callIndex);
    const parsedMeta = _extractMetaData(callData.meta);
    i.proposal = i.proposal.toHuman();
    return {
      title: `${callData.section}.${callData.method}`,
      content: callData.meta?.documentation.join(" "),
      ...parsedMeta
    };
  });
  return { referendums, details, votes };
}

async function subBestNumber() {
  return api.derive.chain
    .bestNumber(res => {
      const n = res.toNumber();
      if (n % 2 === 0) {
        window.send("bestNumber", n);
      }
    })
    .then(unsub => {
      window.unsubBestNumber = unsub;
      return {};
    });
}

export default {
  fetchReferendums,
  subBestNumber
};
