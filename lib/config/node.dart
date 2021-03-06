import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'node.g.dart';

/// Overrides for the Gesell test network
const NodeConfig GesellConfig = const NodeConfig(TypeOverrides_V3_8, PalletOverrides_V3_8);
/// Overrides for the Cantillon test network
const NodeConfig CantillonConfig = const NodeConfig(TypeOverrides_V3_8, PalletOverrides_V3_8);
/// Overrides for the master branch of the `encointer-node`, which is usually used in a local
/// no-tee-dev-setup
const NodeConfig MasterBranchConfig = const NodeConfig(TypeOverrides_V3_8, PalletOverrides_V3_8);
/// Overrides for the sgx-master branch of the `encointer-node`, which is usually used in a local
/// tee-dev-setup
const NodeConfig SgxBranchConfig = const NodeConfig(TypeOverrides_V3_8, PalletOverrides_V3_8);

@JsonSerializable(explicitToJson: true)
/// Config to handle different versions of our nodes by supplying type overwrites
/// and pallet names and methods overwrites.
class NodeConfig {
  /// type overwrites passed to the JS Api type-registry
  final Map<String, dynamic> types;
  /// custom pallet config. The key is the current name of the pallet. The pallet
  /// holds the overwrite data
  final Map<String, Pallet> pallets;

  const NodeConfig(this.types, this.pallets);

  @override
  String toString() {
    return jsonEncode(this);
  }

  factory NodeConfig.fromJson(Map<String, dynamic> json) => _$NodeConfigFromJson(json);
  Map<String, dynamic> toJson() => _$NodeConfigToJson(this);
}


@JsonSerializable(explicitToJson: true)
class Pallet {
  final String name;
  final Map<String, String> calls;

  const Pallet(this.name, this.calls);


  @override
  String toString() {
    return jsonEncode(this);
  }

  factory Pallet.fromJson(Map<String, dynamic> json) => _$PalletFromJson(json);
  Map<String, dynamic> toJson() => _$PalletToJson(this);
}

/// Type overrides needed for the tag v3.8
const TypeOverrides_V3_8 = {
  'CurrencyIdentifier': 'Hash',
  'BalanceType': 'i128',
  'BalanceEntry': {
    'principal': 'i128',
    'last_update': 'BlockNumber'
  },
  'CurrencyCeremony': '(CurrencyIdentifier,CeremonyIndexType)',
  'CurrencyPropertiesType': {
    'name_utf8': 'Vec<u8>',
    'demurrage_per_block': 'Demurrage'
  },
  'GetterArgs': '(AccountId, CurrencyIdentifier)',
  'PublicGetter': {
    '_enum': {
      'total_issuance': 'CurrencyIdentifier',
      'participant_count': 'CurrencyIdentifier',
      'meetup_count': 'CurrencyIdentifier',
      'ceremony_reward': 'CurrencyIdentifier',
      'location_tolerance': 'CurrencyIdentifier',
      'time_tolerance': 'CurrencyIdentifier',
      'scheduler_state': 'CurrencyIdentifier'
    }
  },
  'TrustedGetter': {
    '_enum': {
      'balance': '(AccountId, CurrencyIdentifier)',
      'participant_index': '(AccountId, CurrencyIdentifier)',
      'meetup_index': '(AccountId, CurrencyIdentifier)',
      'attestations': '(AccountId, CurrencyIdentifier)',
      'meetup_registry': '(AccountId, CurrencyIdentifier)'
    }
  },
  'TrustedCall': {
    '_enum': {
      'balance_transfer': '(AccountId, AccountId, CurrencyIdentifier, BalanceType)',
      'ceremonies_register_participant': '(AccountId, CurrencyIdentifier, Option<ProofOfAttendance<MultiSignature, AccountId>>)',
      'ceremonies_register_attestations': '(AccountId, Vec<Attestation<MultiSignature, AccountId, u64>>)',
      'ceremonies_grant_reputation': '(AccountId, CurrencyIdentifier, AccountId)'
    }
  }
};

/// Pallet overrides needed for the tag v3.8
const Map<String, Pallet> PalletOverrides_V3_8 = {
  'encointerCommunities': const Pallet('encointerCurrencies', { 'communityIdentifiers': 'currencyIdentifiers'})
};
