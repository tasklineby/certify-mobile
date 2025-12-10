import 'package:json_annotation/json_annotation.dart';
import 'package:certify_client/core/domain/entities/verification_result.dart';

part 'history_item_model.g.dart';

@JsonSerializable()
class HistoryItemModel {
  final int id;
  @JsonKey(name: 'document_id')
  final int documentId;
  @JsonKey(name: 'user_id')
  final int userId;
  final String status;
  final String message;
  @JsonKey(name: 'scanned_at')
  final DateTime scannedAt;

  HistoryItemModel({
    required this.id,
    required this.documentId,
    required this.userId,
    required this.status,
    required this.message,
    required this.scannedAt,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryItemModelToJson(this);

  VerificationResult toEntity() {
    return VerificationResult(
      status: _mapStatus(status),
      documentId: documentId.toString(),
      timestamp: scannedAt,
      message: message,
      rawStatus: status,
    );
  }

  VerificationStatus _mapStatus(String status) {
    switch (status) {
      case 'green':
        return VerificationStatus.valid;
      case 'yellow':
        return VerificationStatus.warning;
      case 'red':
        return VerificationStatus.invalid;
      default:
        return VerificationStatus.unknown;
    }
  }
}
