import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthInterceptor extends QueuedInterceptorsWrapper {
  final FlutterSecureStorage _storage;
  final Dio
  _dio; // We might need a separate Dio instance for refresh to avoid circular locks if using same client

  // Simple in-memory lock to prevent multiple refreshes
  bool _isRefreshing = false;

  AuthInterceptor(this._storage, @Named('DioClient') this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.read(key: 'refresh_token');

      if (refreshToken == null) {
        await _clearTokens();
        return super.onError(err, handler);
      }

      if (_isRefreshing) {
        // If already refreshing, you might want to queue this request or just fail.
        // For simplicity, we fail non-refresh requests if a refresh is already in progress
        // unless we implement a proper queue.
        // Given internal QueuedInterceptorsWrapper, we are already sequential for THIS Dio instance.
        // However, we are using a SEPARATE Dio instance for refresh.
      }

      try {
        _isRefreshing = true;
        // Use a separate Dio instance to avoid infinite loops or interceptor locks
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: dotenv.env['BASE_URL'] ?? '',
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        final response = await refreshDio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final newAccessToken = response.data['access_token'];
          final newRefreshToken = response.data['refresh_token'];

          await _storage.write(key: 'access_token', value: newAccessToken);
          if (newRefreshToken != null) {
            await _storage.write(key: 'refresh_token', value: newRefreshToken);
          }

          // Update header and retry original request
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';

          final clonedRequest = await _dio.fetch(opts);
          return handler.resolve(clonedRequest);
        } else {
          // Refresh failed
          await _clearTokens();
          return super.onError(err, handler);
        }
      } catch (e) {
        await _clearTokens();
        return super.onError(err, handler);
      } finally {
        _isRefreshing = false;
      }
    }

    super.onError(err, handler);
  }

  Future<void> _clearTokens() async {
    await _storage.deleteAll();
    // Dispatch global event if needed, e.g. via a StreamController injected
  }
}
