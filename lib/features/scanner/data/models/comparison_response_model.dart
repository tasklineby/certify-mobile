import 'package:certify_client/core/domain/entities/verification_result.dart';
import 'package:certify_client/features/scanner/data/models/document_model.dart';
import 'package:certify_client/features/scanner/domain/entities/document.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comparison_response_model.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class ComparisonResponseModel {
  final AnalysisData analysis;
  final DocumentData? document;
  final String message;
  final String status;

  const ComparisonResponseModel({
    required this.analysis,
    this.document,
    required this.message,
    required this.status,
  });

  factory ComparisonResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ComparisonResponseModelFromJson(json);

  ComparisonResponse toEntity() {
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

    return ComparisonResponse(
      status: mappedStatus,
      message: message,
      analysisMessage: analysis.message,
      confidenceScore: analysis.score,
      document: document?.toEntity(),
    );
  }
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class AnalysisData {
  final String message;
  final double score;

  const AnalysisData({required this.message, required this.score});

  factory AnalysisData.fromJson(Map<String, dynamic> json) =>
      _$AnalysisDataFromJson(json);
}

// Domain entity
class ComparisonResponse {
  final VerificationStatus status;
  final String message;
  final String analysisMessage;
  final double confidenceScore;
  final Document? document;

  const ComparisonResponse({
    required this.status,
    required this.message,
    required this.analysisMessage,
    required this.confidenceScore,
    this.document,
  });
}
