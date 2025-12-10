import 'package:injectable/injectable.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../../core/viewmodels/base_view_model.dart';
import 'package:certify_client/core/domain/entities/verification_result.dart';
import 'package:certify_client/features/scanner/data/models/comparison_response_model.dart';
import '../../domain/repositories/scanner_repository.dart';

@injectable
class ScannerViewModel extends BaseViewModel {
  final ScannerRepository _repository;
  final ImagePicker _imagePicker = ImagePicker();

  ScannerViewModel(this._repository);

  VerificationResult? _result;
  VerificationResult? get result => _result;

  String? _scannedHash;
  String? get scannedHash => _scannedHash;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  // Comparison state
  bool _isComparing = false;
  bool get isComparing => _isComparing;

  ComparisonResponse? _comparisonResult;
  ComparisonResponse? get comparisonResult => _comparisonResult;

  List<File> _capturedPhotos = [];
  List<File> get capturedPhotos => _capturedPhotos;

  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  Future<void> init() async {
    // Check permission
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      setError('Camera permission is required to scan.');
    }
  }

  Future<void> onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _result != null) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    _isProcessing = true;
    _scannedHash = code; // Save QR code for comparison
    notifyListeners();

    // Pause camera during verification
    await controller.stop();

    await runWithLoading(() async {
      _result = await _repository.verifyDocument(code);
    });

    _isProcessing =
        false; // Result is now shown, so processing is done, but camera is stopped.
    notifyListeners();
  }

  void resetScanner() {
    _result = null;
    _scannedHash = null;
    _comparisonResult = null;
    _capturedPhotos.clear();
    setError(null);
    _isProcessing = false;
    _isComparing = false;
    notifyListeners();
    controller.start();
  }

  // Photo management for comparison
  Future<void> capturePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        _capturedPhotos.add(File(image.path));
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to capture photo: $e');
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < _capturedPhotos.length) {
      _capturedPhotos.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> compareWithPhotos() async {
    if (_capturedPhotos.isEmpty || _scannedHash == null) {
      setError('No photos captured or QR code missing');
      return;
    }

    _isComparing = true;
    notifyListeners();

    try {
      _comparisonResult = await _repository.compareWithPhotos(
        _scannedHash!,
        _capturedPhotos,
      );
      _isComparing = false;
      notifyListeners();
    } catch (e) {
      _isComparing = false;
      setError('Comparison failed: $e');
      notifyListeners();
    }
  }

  Future<void> compareWithPdf() async {
    if (_scannedHash == null) {
      setError('QR code missing');
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        _isComparing = true;
        notifyListeners();

        final pdfFile = File(result.files.single.path!);
        _comparisonResult = await _repository.compareWithPdf(
          _scannedHash!,
          pdfFile,
        );

        _isComparing = false;
        notifyListeners();
      }
    } catch (e) {
      _isComparing = false;
      setError('PDF comparison failed: $e');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
