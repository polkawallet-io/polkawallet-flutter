import BN from "bn.js";

import { GenericCall, getTypeDef } from "@polkadot/types";

import registry from "./utils/registry";

async function getReferendumVotes(index) {
  return api.derive.democracy.referendumVotesFor(index).then(votesFor => {
    const newState = votesFor.reduce(
      (state, { balance, vote }) => {
        const isDefault = vote.conviction.index === 0;
        const counted = balance
          .muln(isDefault ? 1 : vote.conviction.index)
          .divn(isDefault ? 10 : 1);

        if (vote.isAye) {
          state.voteCountAye++;
          state.votedAye = state.votedAye.add(counted);
        } else {
          state.voteCountNay++;
          state.votedNay = state.votedNay.add(counted);
        }

        state.voteCount++;
        state.votedTotal = state.votedTotal.add(counted);

        return state;
      },
      {
        voteCount: 0,
        voteCountAye: 0,
        voteCountNay: 0,
        votedAye: new BN(0),
        votedNay: new BN(0),
        votedTotal: new BN(0)
      }
    );
    return newState;
  });
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
  const details = referendums.map(i => {
    const callData = registry.findMetaCall(i.proposal.callIndex);
    const parsedMeta = _extractMetaData(callData.meta);
    i.proposal = i.proposal.toHuman();
    return {
      title: `${callData.section}.${callData.method}`,
      content: callData.meta?.documentation.join(" "),
      ...parsedMeta
    };
  });
  return { referendums, details };
}

async function subBestNumber() {
  return api.derive.chain
    .bestNumber(res => {
      window.send("bestNumber", res.toNumber());
    })
    .then(unsub => {
      window.unsubBestNumber = unsub;
      return {};
    });
}

export default { getReferendumVotes, fetchReferendums, subBestNumber };
