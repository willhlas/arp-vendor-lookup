// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lookup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lookup _$LookupFromJson(Map<String, dynamic> json) => Lookup(
  id: (json['id'] as num).toInt(),
  mac: json['mac'] as String,
  vendorName: json['vendor_name'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$LookupToJson(Lookup instance) => <String, dynamic>{
  'id': instance.id,
  'mac': instance.mac,
  'vendor_name': instance.vendorName,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
