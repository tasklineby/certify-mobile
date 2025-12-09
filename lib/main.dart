import 'package:certify_client/core/di/injection.dart';
import 'package:certify_client/core/router/app_router.dart';
import 'package:certify_client/core/theme/app_theme.dart';
import 'package:certify_client/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:certify_client/features/history/presentation/viewmodels/history_view_model.dart';
import 'package:certify_client/features/scanner/presentation/viewmodels/scanner_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  // Initialize Dependency Injection
  configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<ScannerViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<HistoryViewModel>()),
      ],
      child: Builder(
        builder: (context) {
          final authViewModel = context.read<AuthViewModel>();
          return MaterialApp.router(
            title: 'Certify Client',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routerConfig: AppRouter.router(authViewModel),
          );
        },
      ),
    );
  }
}
