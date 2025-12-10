import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:certify_client/core/domain/entities/verification_result.dart';
import 'package:certify_client/features/scanner/data/models/document_model.dart';
import 'package:certify_client/features/scanner/data/models/create_document_request.dart';
import 'package:certify_client/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../../domain/repositories/scanner_repository.dart';

@LazySingleton(as: ScannerRepository)
class ScannerRepositoryImpl implements ScannerRepository {
  final DioClient _dioClient;

  ScannerRepositoryImpl(this._dioClient);

  @override
  Future<VerificationResult> verifyDocument(String qrCode) async {
    try {
      final response = await _dioClient.dio.get(
        '/documents/verify',
        queryParameters: {'hash': qrCode},
      );

      final document = DocumentModel.fromJson(response.data);
      return document.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return VerificationResult(
          status: VerificationStatus.invalid,
          documentId: 'UNKNOWN',
          timestamp: DateTime.now(),
          message: 'Document not found in registry.',
        );
      }
      throw Exception('Failed to verify document: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<String> createDocument(CreateDocumentRequest request) async {
    try {
      final data = request.toJson();
      debugPrint('---- Create document data: $data');
      final response = await _dioClient.dio.post('/documents', data: data);
      return response.data['hash'];
    } on DioException catch (e) {
      throw Exception('Failed to create document: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
