// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/presentation/viewmodels/auth_view_model.dart'
    as _i308;
import '../../features/history/data/repositories/history_repository_impl.dart'
    as _i751;
import '../../features/history/domain/repositories/history_repository.dart'
    as _i142;
import '../../features/history/presentation/viewmodels/history_view_model.dart'
    as _i1030;
import '../../features/local_auth/data/repositories/local_auth_repository_impl.dart'
    as _i775;
import '../../features/local_auth/domain/repositories/local_auth_repository.dart'
    as _i909;
import '../../features/local_auth/presentation/viewmodels/local_auth_view_model.dart'
    as _i440;
import '../../features/scanner/data/repositories/scanner_repository_impl.dart'
    as _i419;
import '../../features/scanner/domain/repositories/scanner_repository.dart'
    as _i816;
import '../../features/scanner/presentation/viewmodels/create_document_view_model.dart'
    as _i137;
import '../../features/scanner/presentation/viewmodels/documents_list_view_model.dart'
    as _i1036;
import '../../features/scanner/presentation/viewmodels/scanner_view_model.dart'
    as _i52;
import '../network/auth_interceptor.dart' as _i908;
import '../network/dio_client.dart' as _i667;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i909.LocalAuthRepository>(
      () => _i775.LocalAuthRepositoryImpl(),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio,
      instanceName: 'DioClient',
    );
    gh.factory<_i908.AuthInterceptor>(
      () => _i908.AuthInterceptor(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i361.Dio>(instanceName: 'DioClient'),
      ),
    );
    gh.factory<_i440.LocalAuthViewModel>(
      () => _i440.LocalAuthViewModel(gh<_i909.LocalAuthRepository>()),
    );
    gh.lazySingleton<_i667.DioClient>(
      () => _i667.DioClient(
        gh<_i361.Dio>(instanceName: 'DioClient'),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i667.DioClient>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.factory<_i308.AuthViewModel>(
      () => _i308.AuthViewModel(
        gh<_i787.AuthRepository>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i816.ScannerRepository>(
      () => _i419.ScannerRepositoryImpl(gh<_i667.DioClient>()),
    );
    gh.lazySingleton<_i142.HistoryRepository>(
      () => _i751.HistoryRepositoryImpl(gh<_i667.DioClient>()),
    );
    gh.factory<_i1030.HistoryViewModel>(
      () => _i1030.HistoryViewModel(gh<_i142.HistoryRepository>()),
    );
    gh.factory<_i137.CreateDocumentViewModel>(
      () => _i137.CreateDocumentViewModel(gh<_i816.ScannerRepository>()),
    );
    gh.factory<_i1036.DocumentsListViewModel>(
      () => _i1036.DocumentsListViewModel(gh<_i816.ScannerRepository>()),
    );
    gh.factory<_i52.ScannerViewModel>(
      () => _i52.ScannerViewModel(gh<_i816.ScannerRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}

class _$NetworkModule extends _i667.NetworkModule {}
