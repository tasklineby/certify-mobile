import 'package:certify_client/core/domain/entities/verification_result.dart';
import 'package:certify_client/features/scanner/domain/entities/document.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_model.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class DocumentModel {
  final DocumentData? document;
  final String message;
  final String status;

  const DocumentModel({
    this.document,
    required this.message,
    required this.status,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);

  VerificationResult toEntity() {
    VerificationStatus mappedStatus;
    final lowerStatus = status.toLowerCase();

    if (lowerStatus == 'green') {
      mappedStatus = VerificationStatus.valid;
    } else if (lowerStatus == 'yellow') {
      mappedStatus = VerificationStatus.warning;
    } else if (lowerStatus == 'red') {
      mappedStatus = VerificationStatus.invalid;
    } else {
      mappedStatus = VerificationStatus.unknown;
    }

    return VerificationResult(
      status: mappedStatus,
      documentId: document?.id.toString(),
      timestamp: DateTime.now(),
      message: message,
      rawStatus: status,
      metadata: {
        'document_id': document?.id,
        'company_id': document?.companyId,
        'name': document?.name,
        'type': document?.type,
        'summary': document?.summary,
        'scan_count': document?.scanCount,
        'expiration_date': document?.expirationDate?.toIso8601String(),
      },
    );
  }
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class DocumentData {
  final int? id;
  final int? companyId;
  final String? name;
  final String? type;
  final String? summary;
  final int? scanCount;
  final DateTime? expirationDate;
  final String? fileName;

  const DocumentData({
    this.id,
    this.companyId,
    this.name,
    this.type,
    this.summary,
    this.scanCount,
    this.expirationDate,
    this.fileName,
  });

  factory DocumentData.fromJson(Map<String, dynamic> json) =>
      _$DocumentDataFromJson(json);

  Document toEntity() {
    return Document(
      id: id ?? 0,
      companyId: companyId ?? 0,
      name: name ?? '',
      type: type ?? '',
      summary: summary ?? '',
      scanCount: scanCount,
      expirationDate: expirationDate,
      fileName: fileName,
    );
  }
}
