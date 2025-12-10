// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comparison_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComparisonResponseModel _$ComparisonResponseModelFromJson(
  Map<String, dynamic> json,
) => ComparisonResponseModel(
  analysis: AnalysisData.fromJson(json['analysis'] as Map<String, dynamic>),
  document: json['document'] == null
      ? null
      : DocumentData.fromJson(json['document'] as Map<String, dynamic>),
  message: json['message'] as String,
  status: json['status'] as String,
);

AnalysisData _$AnalysisDataFromJson(Map<String, dynamic> json) => AnalysisData(
  message: json['message'] as String,
  score: (json['score'] as num).toDouble(),
);
