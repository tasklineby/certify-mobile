import 'package:json_annotation/json_annotation.dart';

part 'create_document_request.g.dart';

@JsonSerializable(includeIfNull: false)
class CreateDocumentRequest {
  @JsonKey(name: 'expiration_date')
  final String expirationDate;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'summary')
  final String summary;

  @JsonKey(name: 'type')
  final String type;

  CreateDocumentRequest({
    required this.name,
    required this.summary,
    required this.type,
    required this.expirationDate,
  });

  Map<String, dynamic> toJson() => _$CreateDocumentRequestToJson(this);
}
