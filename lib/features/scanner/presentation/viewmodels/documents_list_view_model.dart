import 'package:certify_client/features/scanner/domain/entities/document.dart';
import 'package:certify_client/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:certify_client/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  Future<void> openDocument(BuildContext context, Document document) async {
    _isLoading = true;
    notifyListeners();

    try {
      final filePath = await _repository.downloadDocument(
        document.id,
        document.fileName ?? 'document_${document.id}.pdf',
      );

      _isLoading = false;
      notifyListeners();

      if (filePath != null && context.mounted) {
        context.push(
          '/document-viewer',
          extra: {'filePath': filePath, 'title': document.name},
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download document'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
