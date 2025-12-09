import 'dart:math';
import 'package:injectable/injectable.dart';
import 'package:certify_client/core/domain/entities/verification_result.dart';
import '../../domain/repositories/history_repository.dart';

@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImpl implements HistoryRepository {
  @override
  Future<List<VerificationResult>> getHistory() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Generate mock data
    return List.generate(15, (index) {
      final random = Random(index); // Deterministic random for consistent list
      final status = VerificationStatus
          .values[random.nextInt(VerificationStatus.values.length)];
      final daysAgo = random.nextInt(30);

      return VerificationResult(
        status: status,
        documentId: 'DOC-${1000 + index}-${random.nextInt(9999)}',
        timestamp: DateTime.now().subtract(
          Duration(days: daysAgo, hours: random.nextInt(24)),
        ),
        message: _getMessageForStatus(status),
      );
    });
  }

  String _getMessageForStatus(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.valid:
        return 'Document authentic and verified.';
      case VerificationStatus.warning:
        return 'Document valid but expires soon.';
      case VerificationStatus.invalid:
        return 'Document verification failed.';
    }
  }
}
