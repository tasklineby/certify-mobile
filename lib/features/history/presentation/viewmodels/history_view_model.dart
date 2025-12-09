import 'package:injectable/injectable.dart';
import 'package:certify_client/core/viewmodels/base_view_model.dart';
import 'package:certify_client/core/domain/entities/verification_result.dart';
import '../../domain/repositories/history_repository.dart';

@injectable
class HistoryViewModel extends BaseViewModel {
  final HistoryRepository _repository;

  List<VerificationResult> _history = [];
  List<VerificationResult> get history => _history;

  HistoryViewModel(this._repository);

  Future<void> loadHistory() async {
    runWithLoading(() async {
      _history = await _repository.getHistory();
    });
  }
}
