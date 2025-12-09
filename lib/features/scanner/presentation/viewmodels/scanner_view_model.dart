import 'package:injectable/injectable.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/viewmodels/base_view_model.dart';
import 'package:certify_client/core/domain/entities/verification_result.dart';
import '../../domain/repositories/scanner_repository.dart';

@injectable
class ScannerViewModel extends BaseViewModel {
  final ScannerRepository _repository;

  ScannerViewModel(this._repository);

  VerificationResult? _result;
  VerificationResult? get result => _result;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

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
    setError(null);
    _isProcessing = false;
    notifyListeners();
    controller.start();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
