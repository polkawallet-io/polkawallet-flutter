import { GenericCall, getTypeDef } from "@polkadot/types";
import {
  formatBalance,
  stringToU8a,
  BN_ZERO,
  hexToString,
  hexToU8a,
} from "@polkadot/util";

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
      };
    }
  );
  return { referendums, details };
}

async function fetchProposals() {
  const proposals = await api.derive.democracy.proposals();
  return proposals.map((e) => {
    if (e.image && e.image.proposal) {
      e.image.proposal = _transfromProposalMeta(e.image.proposal);
    }
    return e;
  });
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

const TREASURY_ACCOUNT = stringToU8a("modlpy/trsry".padEnd(32, "\0"));

async function getTreasuryOverview() {
  const proposals = await api.derive.treasury.proposals();
  const balance = await api.derive.balances.account(TREASURY_ACCOUNT);
  proposals.balance = formatBalance(balance.freeBalance, {
    forceUnit: "-",
    withSi: false,
  }).split(".")[0];
  proposals.proposals.forEach((e) => {
    if (e.council.length) {
      e.council.forEach((i) => {
        i.proposal = _transfromProposalMeta(i.proposal);
      });
    }
  });
  return proposals;
}

async function getTreasuryTips() {
  const tipKeys = await api.query.treasury.tips.keys();
  const tipHashes = tipKeys.map((key) => key.args[0].toHex());
  const optTips = await api.query.treasury.tips.multi(tipHashes);
  const tips = optTips
    .map((opt, index) => [tipHashes[index], opt.unwrapOr(null)])
    .filter((val) => !!val[1])
    .sort((a, b) =>
      a[1].closes.unwrapOr(BN_ZERO).cmp(b[1].closes.unwrapOr(BN_ZERO))
    );
  return Promise.all(
    tips.map(async (tip) => {
      const detail = tip[1].toJSON();
      const reason = await api.query.treasury.reasons(detail.reason);
      const tips = detail.tips.map((e) => ({ address: e[0], value: e[1] }));
      return {
        hash: tip[0],
        ...detail,
        reason: reason.isSome ? hexToString(reason.unwrap().toHex()) : null,
        tips,
      };
    })
  );
}

async function makeTreasuryProposalSubmission(id, isReject) {
  const members = await (
    api.query.electionsPhragmen || api.query.elections
  ).members();
  const councilThreshold = Math.ceil(members.length * 0.6);
  const proposal = isReject
    ? api.tx.treasury.rejectProposal(id)
    : api.tx.treasury.approveProposal(id);
  return api.tx.council.propose(councilThreshold, proposal, proposal.length);
}

async function getCouncilMotions() {
  const motions = await api.derive.council.proposals();
  motions.forEach((e) => {
    e.proposal = _transfromProposalMeta(e.proposal);
  });
  return motions;
}

function _transfromProposalMeta(proposal) {
  const meta = api.registry.findMetaCall(proposal.callIndex).toJSON();
  let doc = "";
  for (let i = 0; i < meta.documentation.length; i++) {
    if (meta.documentation[i].length) {
      doc += meta.documentation[i];
    } else {
      break;
    }
  }
  meta.documentation = doc;
  const json = proposal.toHuman();
  if (json.method == "setCode") {
    const args = json.args;
    json.args = [
      args[0].slice(0, 16) + "..." + args[0].slice(args[0].length - 16),
    ];
  }
  return {
    ...json,
    meta,
  };
}

export default {
  fetchReferendums,
  fetchProposals,
  fetchCouncilVotes,
  getCouncilMotions,
  getTreasuryOverview,
  getTreasuryTips,
  makeTreasuryProposalSubmission,
};
