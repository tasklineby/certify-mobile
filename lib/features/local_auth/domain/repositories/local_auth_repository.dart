/// Repository interface for Authentication operations.
abstract class LocalAuthRepository {
  Future<bool> checkBiometricsAvailable();
  Future<bool> authenticateWithBiometrics();
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<bool> isPinSet();
}
