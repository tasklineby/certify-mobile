import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/viewmodels/base_view_model.dart';
import '../../data/models/create_document_request.dart';
import '../../domain/repositories/scanner_repository.dart';

@injectable
class CreateDocumentViewModel extends BaseViewModel {
  final ScannerRepository _repository;

  CreateDocumentViewModel(this._repository);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();

  // Type selection
  final List<String> documentTypes = ['agreement', 'certificate', 'license'];
  String _selectedType = 'agreement';
  String get selectedType => _selectedType;

  // Date selection
  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  void setType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    summaryController.dispose();
    super.dispose();
  }

  Future<bool> submit() async {
    if (nameController.text.isEmpty) {
      setError('Please enter a name');
      return false;
    }
    if (summaryController.text.isEmpty) {
      setError('Please enter a summary');
      return false;
    }
    if (_selectedDate == null) {
      setError('Please select an expiration date');
      return false;
    }

    setLoading(true);
    setError(null); // Clear previous errors

    try {
      final request = CreateDocumentRequest(
        name: nameController.text.trim(),
        summary: summaryController.text.trim(),
        type: _selectedType,
        expirationDate: _selectedDate!.toUtc().toIso8601String(),
      );

      await _repository.createDocument(request);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
}
