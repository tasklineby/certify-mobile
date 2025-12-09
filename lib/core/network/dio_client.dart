import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'auth_interceptor.dart';

@module
abstract class NetworkModule {
  @Named('DioClient')
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? 'http://localhost:8080',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // We can't inject AuthInterceptor here easily due to circular dependency if AuthInterceptor needs Dio.
    // However, AuthInterceptor needs Dio to retry? No, it needs Dio to retry the ORIGINAL request.
    // It can use the provided Dio instance.
    // To solve circular dep:
    // 1. Create Dio.
    // 2. Add interceptor later?
    // OR: Inject Storage into Module function.
    return dio;
  }

  // We register AuthInterceptor as a singleton or factory, but we need to add it to Dio.
  // A cleaner way is to have a DioClient class wrapper.
}

@lazySingleton
class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  DioClient(@Named('DioClient') this._dio, this._storage) {
    _dio.interceptors.add(AuthInterceptor(_storage, _dio));

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Dio get dio => _dio;
}
