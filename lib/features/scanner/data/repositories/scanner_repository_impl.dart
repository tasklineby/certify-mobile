import 'package:injectable/injectable.dart';
import 'package:certify_client/core/domain/entities/verification_result.dart';
import '../../domain/repositories/scanner_repository.dart';

@LazySingleton(as: ScannerRepository)
class ScannerRepositoryImpl implements ScannerRepository {
  @override
  Future<VerificationResult> verifyDocument(String qrCode) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final timestamp = DateTime.now();

    if (qrCode.toLowerCase().contains('valid')) {
      return VerificationResult(
        status: VerificationStatus.valid,
        documentId: 'DOC-${timestamp.millisecondsSinceEpoch}',
        timestamp: timestamp,
        message: 'Document is authentic and verified.',
      );
    } else if (qrCode.toLowerCase().contains('warning')) {
      return VerificationResult(
        status: VerificationStatus.warning,
        documentId: 'DOC-${timestamp.millisecondsSinceEpoch}',
        timestamp: timestamp,
        message: 'Document valid but expires soon.',
      );
    } else {
      return VerificationResult(
        status: VerificationStatus.invalid,
        documentId: 'UNKNOWN',
        timestamp: timestamp,
        message: 'Document could not be verified in the system.',
      );
    }
  }
}
