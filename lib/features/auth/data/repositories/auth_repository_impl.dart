import 'package:certify_client/core/network/dio_client.dart';
import 'package:certify_client/features/auth/data/models/auth_request_models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl(this._dioClient, this._storage);

  @override
  Future<void> login(String email, String password) async {
    try {
      final requestDto = LoginRequestDto(email: email, password: password);
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: requestDto.toJson(),
      );

      await _saveTokens(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
      final requestDto = RegisterRequestDto(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        companyId: 1, // Hardcoded for now as per requirements
      );
      final response = await _dioClient.dio.post(
        '/auth/register',
        data: requestDto.toJson(),
      );

      await _saveTokens(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        final requestDto = LogoutRequestDto(refreshToken: refreshToken);
        // Authorization header is auto-injected by AuthInterceptor if token exists
        await _dioClient.dio.post('/auth/logout', data: requestDto.toJson());
      }
    } catch (e) {
      // Ignore logout errors, just clear local state
    } finally {
      await _storage.deleteAll();
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final accessToken = data['access_token'];
    final refreshToken = data['refresh_token'];

    if (accessToken != null) {
      await _storage.write(key: 'access_token', value: accessToken);
    }
    if (refreshToken != null) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
  }
}
