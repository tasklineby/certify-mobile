import 'package:injectable/injectable.dart';
import 'package:certify_client/core/viewmodels/base_view_model.dart';
import '../../domain/repositories/local_auth_repository.dart';

@injectable
class LocalAuthViewModel extends BaseViewModel {
  final LocalAuthRepository _repository;

  LocalAuthViewModel(this._repository);

  String _pin = '';
  String get pin => _pin;

  bool _isSetupMode = false;
  bool get isSetupMode => _isSetupMode;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _canCheckBiometrics = false;
  bool get canCheckBiometrics => _canCheckBiometrics;

  /// Defines how many digits the PIN should have.
  static const int pinLength = 4;

  Future<void> init() async {
    runWithLoading(() async {
      final hasPin = await _repository.isPinSet();
      _isSetupMode = !hasPin;
      _canCheckBiometrics = await _repository.checkBiometricsAvailable();
    });
  }

  void addDigit(String digit) {
    if (_pin.length < pinLength) {
      _pin += digit;
      notifyListeners();
      if (_pin.length == pinLength) {
        _submitPin();
      }
    }
  }

  void removeDigit() {
    if (_pin.isNotEmpty) {
      _pin = _pin.substring(0, _pin.length - 1);
      setError(null); // Clear error on edit
      notifyListeners();
    }
  }

  void clearPin() {
    _pin = '';
    notifyListeners();
  }

  Future<void> _submitPin() async {
    if (_isSetupMode) {
      // Setup new PIN
      // In a real app, you'd ask for confirmation (enter twice)
      await runWithLoading(() async {
        await _repository.setPin(_pin);
        _isSetupMode = false;
        _isAuthenticated = true; // Auto-login after setup
      });
    } else {
      // Verify PIN
      await runWithLoading(() async {
        final isValid = await _repository.verifyPin(_pin);
        if (isValid) {
          _isAuthenticated = true;
          setError(null);
        } else {
          setError('Invalid PIN');
          clearPin();
        }
      });
    }
  }

  Future<void> authenticateWithBiometrics() async {
    if (!_canCheckBiometrics) return;

    await runWithLoading(() async {
      final authenticated = await _repository.authenticateWithBiometrics();
      if (authenticated) {
        _isAuthenticated = true;
        setError(null);
      }
    });
  }
}
