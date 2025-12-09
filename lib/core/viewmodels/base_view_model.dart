import 'package:flutter/foundation.dart';

/// BaseViewModel to handle common UI states: loading and error.
/// Extended by other ViewModels to reduce boilerplate.
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Helper to run async tasks with loading state handling.
  Future<void> runWithLoading(Future<void> Function() action) async {
    try {
      setLoading(true);
      setError(null);
      await action();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
