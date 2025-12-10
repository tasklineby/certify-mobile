import 'dart:io';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/viewmodels/base_view_model.dart';
import '../../data/models/create_document_request.dart';
import '../../domain/repositories/scanner_repository.dart';

@injectable
class CreateDocumentViewModel extends BaseViewModel {
  final ScannerRepository _repository;
  final ImagePicker _imagePicker = ImagePicker();

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

  // File selection
  File? _selectedFile;
  File? get selectedFile => _selectedFile;

  void setType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        _selectedFile = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to capture image: $e');
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        _selectedFile = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to pick image: $e');
    }
  }

  Future<void> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        _selectedFile = File(result.files.single.path!);
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to pick file: $e');
    }
  }

  void removeFile() {
    _selectedFile = null;
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
    if (_selectedFile == null) {
      setError('Please attach a file');
      return false;
    }

    setLoading(true);
    setError(null);

    try {
      final request = CreateDocumentRequest(
        name: nameController.text.trim(),
        summary: summaryController.text.trim(),
        type: _selectedType,
        expirationDate: _selectedDate!.toUtc().toIso8601String(),
      );

      await _repository.createDocument(request, _selectedFile!);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
}
