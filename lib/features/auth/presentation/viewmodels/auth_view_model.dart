import 'package:certify_client/core/viewmodels/base_view_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/auth_repository.dart';

@injectable
class AuthViewModel extends BaseViewModel {
  final AuthRepository _repository;
  final FlutterSecureStorage _storage;

  AuthViewModel(this._repository, this._storage);

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuth() async {
    final token = await _storage.read(key: 'access_token');
    _isAuthenticated = token != null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await runWithLoading(() async {
      await _repository.login(email, password);
      _isAuthenticated = true;
    });
  }

  Future<void> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    await runWithLoading(() async {
      await _repository.register(firstName, lastName, email, password);
      _isAuthenticated = true;
    });
  }

  Future<void> logout() async {
    await runWithLoading(() async {
      await _repository.logout();
      _isAuthenticated = false;
    });
  }
}
