import 'package:certify_client/core/domain/entities/verification_result.dart';

import 'package:certify_client/features/scanner/data/models/create_document_request.dart';

abstract class ScannerRepository {
  Future<VerificationResult> verifyDocument(String qrCode);
  Future<String> createDocument(CreateDocumentRequest request);
}
