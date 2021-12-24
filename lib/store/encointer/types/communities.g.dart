// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'communities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityMetadata _$CommunityMetadataFromJson(Map<String, dynamic> json) {
  return CommunityMetadata(
    json['name'] as String,
    json['symbol'] as String,
    json['icons'] as String,
    json['url'] as String,
    json['theme'] == null ? null : CustomTheme.fromJson(json['theme'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CommunityMetadataToJson(CommunityMetadata instance) => <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'icons': instance.icons,
      'url': instance.url,
      'theme': instance.theme?.toJson(),
    };

CidName _$CidNameFromJson(Map<String, dynamic> json) {
  return CidName(
    json['cid'] == null ? null : CommunityIdentifier.fromJson(json['cid'] as Map<String, dynamic>),
    json['name'] as String,
  );
}

Map<String, dynamic> _$CidNameToJson(CidName instance) => <String, dynamic>{
      'cid': instance.cid?.toJson(),
      'name': instance.name,
    };
