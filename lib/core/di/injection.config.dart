// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
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
import '../../features/scanner/data/repositories/scanner_repository_impl.dart'
    as _i419;
import '../../features/scanner/domain/repositories/scanner_repository.dart'
    as _i816;
import '../../features/scanner/presentation/viewmodels/scanner_view_model.dart'
    as _i52;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i816.ScannerRepository>(
      () => _i419.ScannerRepositoryImpl(),
    );
    gh.lazySingleton<_i787.AuthRepository>(() => _i153.AuthRepositoryImpl());
    gh.lazySingleton<_i142.HistoryRepository>(
      () => _i751.HistoryRepositoryImpl(),
    );
    gh.factory<_i308.AuthViewModel>(
      () => _i308.AuthViewModel(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i1030.HistoryViewModel>(
      () => _i1030.HistoryViewModel(gh<_i142.HistoryRepository>()),
    );
    gh.factory<_i52.ScannerViewModel>(
      () => _i52.ScannerViewModel(gh<_i816.ScannerRepository>()),
    );
    return this;
  }
}
