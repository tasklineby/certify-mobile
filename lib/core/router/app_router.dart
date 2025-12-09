import 'package:go_router/go_router.dart';
import 'placeholders.dart'; // Temporary import for placeholders

/// AppRouter defines the navigation logic using GoRouter.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
        redirect: (context, state) {
          // Placeholder redirection logic
          // Check auth status here later
          // return '/login';
          return null; // Stay on splash for now, or move to login
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
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
    ],
  );
}
