import 'package:certify_client/features/scanner/domain/entities/document.dart';
import 'package:certify_client/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class DocumentsListViewModel extends ChangeNotifier {
  final ScannerRepository _repository;

  DocumentsListViewModel(this._repository);

  List<Document> _documents = [];
  List<Document> get documents => _documents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    await fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _documents = await _repository.getCompanyDocuments();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
