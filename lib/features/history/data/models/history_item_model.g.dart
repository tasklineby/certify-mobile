// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryItemModel _$HistoryItemModelFromJson(Map<String, dynamic> json) =>
    HistoryItemModel(
      id: (json['id'] as num).toInt(),
      documentId: (json['document_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      status: json['status'] as String,
      message: json['message'] as String,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
    );

Map<String, dynamic> _$HistoryItemModelToJson(HistoryItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'document_id': instance.documentId,
      'user_id': instance.userId,
      'status': instance.status,
      'message': instance.message,
      'scanned_at': instance.scannedAt.toIso8601String(),
    };
