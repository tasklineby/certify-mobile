// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentModel _$DocumentModelFromJson(Map<String, dynamic> json) =>
    DocumentModel(
      document: json['document'] == null
          ? null
          : DocumentData.fromJson(json['document'] as Map<String, dynamic>),
      message: json['message'] as String,
      status: json['status'] as String,
    );

DocumentData _$DocumentDataFromJson(Map<String, dynamic> json) => DocumentData(
  id: (json['id'] as num?)?.toInt(),
  companyId: (json['company_id'] as num?)?.toInt(),
  name: json['name'] as String?,
  type: json['type'] as String?,
  summary: json['summary'] as String?,
  scanCount: (json['scan_count'] as num?)?.toInt(),
  expirationDate: json['expiration_date'] == null
      ? null
      : DateTime.parse(json['expiration_date'] as String),
);
