import { GenericCall, getTypeDef } from "@polkadot/types";

import { approxChanges } from "../utils/referendumApproxChanges";

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

async function fetchReferendums(address) {
  const referendums = await api.derive.democracy.referendums();
  const sqrtElectorate = await api.derive.democracy.sqrtElectorate();
  const details = referendums.map(
    ({ image, imageHash, status, votedAye, votedNay, votedTotal, votes }) => {
      let callData;
      let parsedMeta = {};
      if (image && image.proposal) {
        callData = api.registry.findMetaCall(image.proposal.callIndex);
        parsedMeta = _extractMetaData(callData.meta);
        image.proposal = image.proposal.toHuman();
        if (image.proposal.method == "setCode") {
          const args = image.proposal.args;
          image.proposal.args = [
            args[0].slice(0, 16) + "..." + args[0].slice(args[0].length - 16),
          ];
        }
      }

      const changes = approxChanges(status.threshold, sqrtElectorate, {
        votedAye,
        votedNay,
        votedTotal,
      });

      const voted = votes.find((i) => i.accountId.toString() == address);
      const userVoted = voted
        ? {
            balance: voted.balance,
            vote: voted.vote.toHuman(),
          }
        : null;
      return {
        title: callData ? `${callData.section}.${callData.method}` : null,
        content: callData ? callData.meta?.documentation.join(" ") : null,
        imageHash: imageHash.toHuman(),
        changes: {
          changeAye: changes.changeAye.toString(),
          changeNay: changes.changeNay.toString(),
        },
        userVoted,
        ...parsedMeta,
      };
    }
  );
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
