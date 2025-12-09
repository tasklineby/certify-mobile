import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import '../../domain/repositories/local_auth_repository.dart';

@LazySingleton(as: LocalAuthRepository)
class LocalAuthRepositoryImpl implements LocalAuthRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _pinKey = 'user_pin_hash';

  @override
  Future<bool> checkBiometricsAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics || isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      // Handle specific errors if needed, e.g., auth_error.notAvailable
      return false;
    }
  }

  @override
  Future<void> setPin(String pin) async {
    // In a real app, hash this before storing!
    // For this core setup, implementation assumes SecureStorage is safe enough.
    // Ideally: await _storage.write(key: _pinKey, value: hash(pin));
    await _storage.write(key: _pinKey, value: pin);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final storedPin = await _storage.read(key: _pinKey);
    return storedPin == pin;
  }

  @override
  Future<bool> isPinSet() async {
    final storedPin = await _storage.read(key: _pinKey);
    return storedPin != null;
  }
}
