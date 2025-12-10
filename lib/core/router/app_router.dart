import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:certify_client/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:certify_client/features/auth/presentation/screens/login_screen.dart';
import 'package:certify_client/features/auth/presentation/screens/register_screen.dart';
import 'package:certify_client/features/local_auth/presentation/viewmodels/local_auth_view_model.dart';
import 'package:certify_client/features/local_auth/presentation/screens/local_auth_screen.dart';
import 'package:certify_client/features/scanner/presentation/screens/scanner_screen.dart';
import 'package:certify_client/features/history/presentation/screens/history_screen.dart';
import 'package:certify_client/features/scanner/presentation/screens/create_document_screen.dart';
import 'placeholders.dart'
    hide
        LoginScreen,
        ScannerScreen,
        HistoryScreen; // Temporary import for placeholders

/// AppRouter defines the navigation logic using GoRouter.
class AppRouter {
  static GoRouter router(
    AuthViewModel authViewModel,
    LocalAuthViewModel localAuthViewModel,
  ) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: Listenable.merge([authViewModel, localAuthViewModel]),
      redirect: (context, state) {
        final isAuth = authViewModel.isAuthenticated;
        final isLocalAuth = localAuthViewModel.isAuthenticated;

        final loc = state.matchedLocation;
        final isLoginRoute = loc == '/login';
        final isRegisterRoute = loc == '/register';
        final isLocalAuthRoute = loc == '/local-auth';
        final isSplash = loc == '/';

        // 1. App Start / Auth Check
        // If not authenticated (server), must go to Login (or Register)
        if (!isAuth) {
          // Allow access to login and register pages
          if (isLoginRoute || isRegisterRoute) return null;
          return '/login';
        }

        // 2. If Server Authenticated, check Local Auth (PIN/Bio)
        // If not locally authenticated, must go to Local Auth screen
        if (!isLocalAuth) {
          if (isLocalAuthRoute) return null;
          return '/local-auth';
        }

        // 3. If Fully Authenticated
        // If user is still on login, register, or local-auth pages, redirect to home
        if (isLoginRoute || isRegisterRoute || isLocalAuthRoute || isSplash) {
          return '/scanner';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
          // Redirect logic above handles the move from splash
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/local-auth',
          name: 'local-auth',
          builder: (context, state) => const LocalAuthScreen(),
        ),
        GoRoute(
          path: '/scanner',
          name: 'scanner',
          builder: (context, state) => const ScannerScreen(),
        ),
        GoRoute(
          path: '/history',
          name: 'history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/create-document',
          name: 'create-document',
          builder: (context, state) => const CreateDocumentScreen(),
        ),
      ],
    );
  }
}
