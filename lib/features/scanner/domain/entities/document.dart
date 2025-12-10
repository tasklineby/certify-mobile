import 'package:equatable/equatable.dart';

class Document extends Equatable {
  final int id;
  final int companyId;
  final String name;
  final String type;
  final String summary;
  final int? scanCount;
  final DateTime? expirationDate;
  final String? fileName;

  const Document({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    required this.summary,
    this.scanCount,
    this.expirationDate,
    this.fileName,
  });

  @override
  List<Object?> get props => [
    id,
    companyId,
    name,
    type,
    summary,
    scanCount,
    expirationDate,
    fileName,
  ];
}
