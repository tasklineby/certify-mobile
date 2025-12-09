import 'package:certify_client/core/di/injection.dart';
import 'package:certify_client/core/router/app_router.dart';
import 'package:certify_client/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  // Initialize Dependency Injection
  configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Certify Client',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
