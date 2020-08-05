const int treasuryCount = 36;
const String treasuryBalance = "219,416,580,192,171,241";
const Map<String, dynamic> treasuryProposal33 = {
  "proposer": "DfyDF9aumWDoF6FhUEsw6LJVvCfv3eCV8EnM3zunEkoiwSG",
  "value": 2300000000000000,
  "beneficiary": "DfyDF9aumWDoF6FhUEsw6LJVvCfv3eCV8EnM3zunEkoiwSG",
  "bond": 115000000000000
};
const Map<String, dynamic> councilProposalOf36 = {
  "hash": "0xd917e5b9558a7f2a6244ccbec580970d9199b5872bb8050c97533d042cb48914",
  "proposal": {
    "callIndex": "0x1202",
    "args": [36],
    "meta": {
      "name": "approve_proposal",
      "args": [
        {"name": "proposal_id", "type": "Compact<ProposalIndex>"}
      ],
      "documentation":
          " Approve a proposal. At a later time, the proposal will be allocated to the beneficiary and the original deposit will be returned."
    }
  },
  "votes": {
    "index": 178,
    "threshold": 11,
    "ayes": [
      "H9eSvWe34vQDJAWckeTHWSqSChRat8bgKHG39GC1fjvEm7y",
      "GLVeryFRbg5hEKvQZcAnLvXZEXhiYaBjzSDwrXBXrfPF7wj",
      "Hjuii5eGVttxjAqQrPLVN3atxBDXPc4hNpXF6cPhbwzvtis",
      "J9nD3s7zssCX7bion1xctAF6xcVexcpy2uwy4jTm9JL8yuK",
      "EGVQCe73TpFyAZx5uKfE1222XfkT3BSKozjgcqzLBnc5eYo",
      "DTLcUu92NoQw4gg6VmNgXeYQiNywDhfYMQBPYg2Y1W6AkJF",
      "Gth5jQA6v9EFbpqSPgXcsvpGSrbTdWwmBADnqa36ptjs5m5",
      "FcxNWVy5RESDsErjwyZmPCW6Z8Y3fbfLzmou34YZTrbcraL",
      "GvyfytrxFQbHK8ZFNT3h12dJPfBXFjVV7k98cXni8VAgjKX",
      "DfiSM1qqP11ECaekbA64L2ENcsWEpGk8df8wf1LAfV2sBd4",
      "HSNBs8VHxcZiqz9NfSQq2YaznTa8BzSvuEWVe4uTihcGiQN"
    ],
    "nays": [],
    "end": 3212205
  }
};
final Map<String, dynamic> treasuryOverview = {
  "approvals": [
    {"council": [], "id": 33, "proposal": treasuryProposal33},
    {
      "council": [],
      "id": 34,
      "proposal": {
        "proposer": "FyLYnuNoMAVkz1VZMMGZFHDPghQQm1916fCon1CqNt2aXbX",
        "value": 2500000000000000,
        "beneficiary": "FyLYnuNoMAVkz1VZMMGZFHDPghQQm1916fCon1CqNt2aXbX",
        "bond": 125000000000000
      }
    },
    {
      "council": [],
      "id": 35,
      "proposal": {
        "proposer": "D3akXZ5Aawj7ZQMsvL5oTcxaWpJTLXQPJxhnG5HsBQSswBs",
        "value": 4400000000000000,
        "beneficiary": "D3akXZ5Aawj7ZQMsvL5oTcxaWpJTLXQPJxhnG5HsBQSswBs",
        "bond": 220000000000000
      }
    }
  ],
  "proposalCount": treasuryCount,
  "proposals": [
    {
      "council": [councilProposalOf36],
      "id": 36,
      "proposal": {
        "proposer": "DWUAQt9zcpnQt5dT48NwWbJuxQ78vKRK9PRkHDkGDn9TJ1j",
        "value": 361110000000000,
        "beneficiary": "DWUAQt9zcpnQt5dT48NwWbJuxQ78vKRK9PRkHDkGDn9TJ1j",
        "bond": 18055500000000
      }
    }
  ],
  "balance": treasuryBalance,
};

const Map<String, dynamic> tip0x58 = {
  "hash": "0x58d8cf7fe32e228276c89a3abe7298c21787cf3d962f9bd3d453a51b0dd45804",
  "reason":
      "Translation into Russian - https://twitter.com/block_25/status/1277561502954852352",
  "who": "EGX4yJNtThEW9axmM3qB262Z7VVuYuXfWRKvujSxiDJmHy7",
  "finder": "EGX4yJNtThEW9axmM3qB262Z7VVuYuXfWRKvujSxiDJmHy7",
  "deposit": 303333333278,
  "closes": null,
  "tips": [
    {"address": "DTLcUu92NoQw4gg6VmNgXeYQiNywDhfYMQBPYg2Y1W6AkJF", "value": 0},
    {"address": "DfiSM1qqP11ECaekbA64L2ENcsWEpGk8df8wf1LAfV2sBd4", "value": 0},
    {"address": "EGVQCe73TpFyAZx5uKfE1222XfkT3BSKozjgcqzLBnc5eYo", "value": 0}
  ]
};
const Map<String, dynamic> tip0xf2 = {
  "hash": "0xf202c6feae1a7a880f028c665b69b5b35ec8674fdb886282bf5cd943d74fd8aa",
  "reason":
      "For polkadot wiki Japanese transation, 3% and progressing: https://crowdin.com/project/polkadot-wiki/ja#",
  "who": "Gf7EzU2aHeaqFX7AWU93Pb4YDz3vn7fhdYRteNunXYPe9DP",
  "finder": null,
  "closes": null,
  "tips": []
};

const Map<String, dynamic> councilMotion0 = {
  "hash": "0xf3d7d91e7cfb2d484b5b78b40025a6ad90aa286a0851900b9a952393289b95bc",
  "proposal": {
    "args": ["0"],
    "callIndex": "0x1002",
    "method": "approveProposal",
    "section": "treasury",
    "meta": {
      "name": "approve_proposal",
      "args": [
        {"name": "proposal_id", "type": "Compact<ProposalIndex>"}
      ],
      "documentation":
          " Approve a proposal. At a later time, the proposal will be allocated to the beneficiary and the original deposit will be returned."
    }
  },
  "votes": {
    "index": 0,
    "threshold": 4,
    "ayes": ["5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY"],
    "nays": [],
    "end": 146922
  }
};

const List<Map<String, dynamic>> councilMotions = [
  councilMotion0,
  {
    "hash":
        "0x7fb731dc431ed1c4a0d1a4aaf013c8ef534c8bdfff9e2cd876f64d35d8830fdd",
    "proposal": {
      "args": ["1"],
      "callIndex": "0x1001",
      "method": "rejectProposal",
      "section": "treasury",
      "meta": {
        "name": "reject_proposal",
        "args": [
          {"name": "proposal_id", "type": "Compact<ProposalIndex>"}
        ],
        "documentation":
            " Reject a proposed spend. The original deposit will be slashed."
      }
    },
    "votes": {
      "index": 1,
      "threshold": 4,
      "ayes": ["5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY"],
      "nays": [],
      "end": 146996
    }
  }
];

const Map<String, dynamic> proposal0 = {
  "balance": "0x0000000000000000002386f26fc10000",
  "seconds": ["5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY"],
  "image": {
    "at": 2114,
    "balance": 3000000000000,
    "proposal": {
      "args": ["10"],
      "callIndex": "0x1002",
      "method": "approveProposal",
      "section": "treasury",
      "meta": {
        "name": "approve_proposal",
        "args": [
          {"name": "proposal_id", "type": "Compact<ProposalIndex>"}
        ],
        "documentation":
            " Approve a proposal. At a later time, the proposal will be allocated to the beneficiary and the original deposit will be returned."
      }
    },
    "proposer": "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY"
  },
  "imageHash":
      "0x7343bdf358c714b172c64107029b3305396c2e55fd60ac11476032e4bc9d9676",
  "index": 0,
  "proposer": "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY"
};
const Map<String, dynamic> proposal1 = {
  "balance": "0x0000000000000000002386f26fc10000",
  "seconds": [
    "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY",
    "5FHneW46xGXgs5mUiveU4sbTyGBzmstUspZC92UhjJM694ty"
  ],
  "image": {
    "at": 4414,
    "balance": 34000000000000,
    "proposal": {
      "args": [
        "0xb6ec618cb7aaa78ab73d6f91935cc8ab477532742d0eaa4b4e5d8a067b87b963"
      ],
      "callIndex": "0x0904",
      "method": "externalPropose",
      "section": "democracy",
      "meta": {
        "name": "external_propose",
        "args": [
          {"name": "proposal_hash", "type": "Hash"}
        ],
        "documentation":
            " Schedule a referendum to be tabled once it is legal to schedule an external referendum."
      }
    },
    "proposer": "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY"
  },
  "imageHash":
      "0x45565d4c6e75dc437ca69978ac88c3ede8e9d5c9293d1d8214d2aab65d6d77b6",
  "index": 1,
  "proposer": "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY"
};
