import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:certify_client/core/domain/entities/verification_result.dart';
import 'package:certify_client/features/scanner/data/models/document_model.dart';
import 'package:certify_client/features/scanner/domain/entities/document.dart';
import 'package:certify_client/features/scanner/data/models/create_document_request.dart';
import 'package:certify_client/features/scanner/data/models/comparison_response_model.dart';
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
  Future<String> createDocument(
    CreateDocumentRequest request,
    File file,
  ) async {
    try {
      final formData = FormData.fromMap({
        'name': request.name,
        'type': request.type,
        'summary': request.summary,
        'expiration_date': request.expirationDate,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      debugPrint('---- Creating document with file: ${file.path}');
      final response = await _dioClient.dio.post('/documents', data: formData);
      return response.data['hash'];
    } on DioException catch (e) {
      throw Exception('Failed to create document: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<Document>> getCompanyDocuments() async {
    try {
      final response = await _dioClient.dio.get('/documents');
      final List<dynamic> list = response.data;
      return list.map((e) => DocumentData.fromJson(e).toEntity()).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch documents: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<String?> downloadDocument(int documentId, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/$fileName';

      debugPrint('---- Downloading document $documentId to $savePath');
      await _dioClient.dio.download('/documents/$documentId/file', savePath);

      return savePath;
    } on DioException catch (e) {
      debugPrint('Failed to download document: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('An unexpected error occurred: $e');
      return null;
    }
  }

  @override
  Future<ComparisonResponse> compareWithPhotos(
    String hash,
    List<File> photos,
  ) async {
    try {
      final formData = FormData();

      // Add hash field (QR code)
      formData.fields.add(MapEntry('hash', hash));

      // Add multiple photo files
      for (final photo in photos) {
        formData.files.add(
          MapEntry(
            'photos',
            await MultipartFile.fromFile(
              photo.path,
              filename: photo.path.split('/').last,
            ),
          ),
        );
      }

      debugPrint(
        '---- Comparing document with hash: $hash (${photos.length} photos)',
      );
      final response = await _dioClient.dio.post(
        '/documents/compare/photos',
        data: formData,
      );

      final model = ComparisonResponseModel.fromJson(response.data);
      return model.toEntity();
    } on DioException catch (e) {
      throw Exception('Failed to compare with photos: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<ComparisonResponse> compareWithPdf(String hash, File pdf) async {
    try {
      final formData = FormData.fromMap({
        'hash': hash,
        'file': await MultipartFile.fromFile(
          pdf.path,
          filename: pdf.path.split('/').last,
        ),
      });

      debugPrint('---- Comparing document with hash: $hash (PDF)');
      final response = await _dioClient.dio.post(
        '/documents/compare/pdf',
        data: formData,
      );

      final model = ComparisonResponseModel.fromJson(response.data);
      return model.toEntity();
    } on DioException catch (e) {
      throw Exception('Failed to compare with PDF: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
