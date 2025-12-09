import 'package:certify_client/core/domain/entities/verification_result.dart';

abstract class HistoryRepository {
  Future<List<VerificationResult>> getHistory();
}
