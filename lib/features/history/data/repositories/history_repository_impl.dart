import 'package:injectable/injectable.dart';
import 'package:certify_client/core/network/dio_client.dart';
import 'package:certify_client/core/domain/entities/verification_result.dart';
import 'package:certify_client/features/history/data/models/history_item_model.dart';
import '../../domain/repositories/history_repository.dart';

@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImpl implements HistoryRepository {
  final DioClient _dioClient;

  HistoryRepositoryImpl(this._dioClient);

  @override
  Future<List<VerificationResult>> getHistory() async {
    try {
      final response = await _dioClient.dio.get('/history');
      final List<dynamic> data = response.data;

      return data
          .map((json) => HistoryItemModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      // In a real app, we might map exceptions to Failures here
      rethrow;
    }
  }
}
