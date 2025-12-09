import 'package:go_router/go_router.dart';
import 'package:certify_client/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:certify_client/features/auth/presentation/screens/login_screen.dart';
import 'placeholders.dart'
    hide LoginScreen; // Temporary import for placeholders

/// AppRouter defines the navigation logic using GoRouter.
class AppRouter {
  // We need the AuthViewModel to make redirection decisions.
  static GoRouter router(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authViewModel, // Listens to ChangeNotifier
      redirect: (context, state) {
        final isAuthenticated = authViewModel.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';

        // If not authenticated and not on login page, go to login
        if (!isAuthenticated) {
          return isLoginRoute ? null : '/login';
        }

        // If authenticated and on login page, go to home/scanner
        if (isAuthenticated && isLoginRoute) {
          return '/scanner';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
          redirect: (context, state) {
            // Basic splash delay logic could go here,
            // but current auth logic handles the main check.
            // If we are here, we are either checking auth or done.
            // For now, let's redirect to scanner if auth'd or login if not
            if (authViewModel.isAuthenticated) return '/scanner';
            return '/login';
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
}
