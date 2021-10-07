
/// Types used in the bazaar ecosystem.
///
/// In general, there are two different categories of types:
/// * Onchain types: They are minimal and contain just enough data to track all the registered business along with
///   their offerings. They also contain an ipfs-url that points to the richer types living in ipfs.
/// * Ipfs types: They have all the relevant metadata to be served to respective bazaar UIs.

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

// Run: `flutter pub run build_runner build --delete-conflicting-outputs` in order to create/update the *.g.dart
part 'bazaar.g.dart';

/// Business metadata living in ipfs
@JsonSerializable()
class IpfsBusiness {
  IpfsBusiness(this.name, this.description, this.contactInfo, this.imagesCid, this.openingHours);

  /// name of the business
  final String name;
  /// brief description of the business
  final String description;
  /// contact info of the business
  final String contactInfo;
  /// ipfs-cid where the images live
  final String imagesCid;
  /// opening hours of the business
  /// Todo: change to an actual date format instead of string
  final String openingHours;

  @override
  String toString() {
    return jsonEncode(this);
  }

  factory IpfsBusiness.fromJson(Map<String, dynamic> json) =>
      _$IpfsBusinessFromJson(json);
  Map<String, dynamic> toJson() => _$IpfsBusinessToJson(this);
}

/// Offering metadata living in ipfs
@JsonSerializable()
class IpfsOffering {
  IpfsOffering(this.name, this.price, this.description, this.contactInfo, this.imagesCid);

  /// name of the offering
  final String name;
  /// price in community currency
  final int price;
  /// description of the offering
  final String description;
  /// contact info of the business
  final String contactInfo;
  /// ipfs-cid where the offering's images live
  final String imagesCid;

  @override
  String toString() {
    return jsonEncode(this);
  }

  factory IpfsOffering.fromJson(Map<String, dynamic> json) =>
      _$IpfsOfferingFromJson(json);
  Map<String, dynamic> toJson() => _$IpfsOfferingToJson(this);
}

/// Business data living onchain
@JsonSerializable()
class BusinessData {
  BusinessData(this.url, this.lastOid);

  /// ipfs-cid of the corresponding [IpfsBusiness]
  final String url;
  /// monotonic counter of registered offerings
  final int lastOid;

  @override
  String toString() {
    return jsonEncode(this);
  }

  factory BusinessData.fromJson(Map<String, dynamic> json) =>
      _$BusinessDataFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessDataToJson(this);
}

/// Offering data living onchain
@JsonSerializable()
class OfferingData {
  OfferingData(this.url);

  /// ipfs-cid of the corresponding [IpfsOffering]
  final String url;

  @override
  String toString() {
    return jsonEncode(this);
  }

  factory OfferingData.fromJson(Map<String, dynamic> json) =>
      _$OfferingDataFromJson(json);
  Map<String, dynamic> toJson() => _$OfferingDataToJson(this);
}

/// Data type as returned by the rpc `bazaar_getBusinesses`.
///
/// In rust it is defined as a tuple but dart doesn't now that type.
@JsonSerializable()
class AccountBusinessTuple {
  AccountBusinessTuple(this.controller, this.businessData);

  /// accountId of the business's controller
  final String controller;
  /// the business data belonging to [controller]
  final BusinessData businessData;

  @override
  String toString() {
    return jsonEncode(this);
  }

  factory AccountBusinessTuple.fromJson(Map<String, dynamic> json) =>
      _$AccountBusinessTupleFromJson(json);
  Map<String, dynamic> toJson() => _$AccountBusinessTupleToJson(this);
}

/// Key to index businesses onchain. It is passed as argument to the rpc `bazaar_getOfferingsForBusiness`.
@JsonSerializable()
class BusinessIdentifier {
  BusinessIdentifier(this.cid, this.controller);

  /// community identifier of the community the business belongs to
  final String cid;
  /// controller account of the business
  final String controller;

  @override
  String toString() {
    return jsonEncode(this);
  }

  factory BusinessIdentifier.fromJson(Map<String, dynamic> json) =>
      _$BusinessIdentifierFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessIdentifierToJson(this);
}
