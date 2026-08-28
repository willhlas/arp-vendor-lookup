import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lookup.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Lookup extends Equatable {
  const Lookup({
    required this.id,
    required this.mac,
    required this.vendorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lookup.fromJson(Map<String, dynamic> json) => _$LookupFromJson(json);

  final int id;
  final String mac;
  final String? vendorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get found => vendorName != null;

  Map<String, dynamic> toJson() => _$LookupToJson(this);

  @override
  List<Object?> get props => [id, mac, vendorName, createdAt, updatedAt];
}
