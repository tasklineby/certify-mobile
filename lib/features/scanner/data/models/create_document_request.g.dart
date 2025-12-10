// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_document_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDocumentRequest _$CreateDocumentRequestFromJson(
  Map<String, dynamic> json,
) => CreateDocumentRequest(
  name: json['name'] as String,
  summary: json['summary'] as String,
  type: json['type'] as String,
  expirationDate: json['expiration_date'] as String,
);

Map<String, dynamic> _$CreateDocumentRequestToJson(
  CreateDocumentRequest instance,
) => <String, dynamic>{
  'expiration_date': instance.expirationDate,
  'name': instance.name,
  'summary': instance.summary,
  'type': instance.type,
};
