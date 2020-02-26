import BN from "bn.js";

import registry from "./registry";

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

async function findMetaCall(callIndex) {
  const { meta, method, section } = registry.findMetaCall(callIndex);
  window.send("log", meta);
  window.send("log", method);
  window.send("log", section);
  return meta;
}

export default { getReferendumVotes, findMetaCall };
