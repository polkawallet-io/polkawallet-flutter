import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'node.g.dart';

/// Overrides for the Gesell test network
const NodeConfig GesellConfig = const NodeConfig(GesellTypeOverrides, GesellPalletOverrides);

/// Overrides for the Cantillon test network
const NodeConfig CantillonConfig = const NodeConfig(GesellTypeOverrides, GesellPalletOverrides);

/// Overrides for the master branch of the `encointer-node`, which is usually used in a local
/// no-tee-dev-setup
const NodeConfig MasterBranchConfig = const NodeConfig(TypeOverridesDev, PalletOverridesDev);

/// Overrides for the sgx-master branch of the `encointer-node`, which is usually used in a local
/// tee-dev-setup
const NodeConfig SgxBranchConfig = const NodeConfig(GesellTypeOverrides, GesellPalletOverrides);

/// Config to handle different versions of our nodes by supplying type overwrites
/// and pallet names and methods overwrites.
@JsonSerializable(explicitToJson: true)
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

const Map<String, dynamic> TypeOverridesDev = {};
const Map<String, Pallet> PalletOverridesDev = {};

/// Type overrides needed for Gesell
const Map<String, dynamic> GesellTypeOverrides = {};

/// Pallet overrides needed for Gesell
const Map<String, Pallet> GesellPalletOverrides = {};
