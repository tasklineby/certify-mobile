import 'package:certify_client/core/domain/entities/verification_result.dart';

import 'package:certify_client/features/scanner/data/models/create_document_request.dart';

import 'package:certify_client/features/scanner/domain/entities/document.dart';
import 'package:certify_client/features/scanner/data/models/comparison_response_model.dart';

import 'dart:io';

abstract class ScannerRepository {
  Future<VerificationResult> verifyDocument(String qrCode);
  Future<String> createDocument(CreateDocumentRequest request, File file);
  Future<List<Document>> getCompanyDocuments();
  Future<String?> downloadDocument(int documentId, String fileName);
  Future<ComparisonResponse> compareWithPhotos(String hash, List<File> photos);
  Future<ComparisonResponse> compareWithPdf(String hash, File pdf);
}
