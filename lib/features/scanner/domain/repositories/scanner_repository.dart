import 'package:certify_client/core/domain/entities/verification_result.dart';

abstract class ScannerRepository {
  Future<VerificationResult> verifyDocument(String qrCode);
}
