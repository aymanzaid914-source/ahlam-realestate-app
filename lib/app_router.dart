// lib/app_router.dart
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/properties/properties_screen.dart';
import 'screens/properties/property_detail_screen.dart';
import 'screens/projects/projects_screen.dart';
import 'screens/projects/project_detail_screen.dart';
import 'screens/reservations/reservations_screen.dart';
import 'screens/reservations/create_reservation_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/pages/contact_screen.dart';
import 'screens/pages/page_detail_screen.dart';
import 'screens/main_scaffold.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final isAuth = auth.status == AuthStatus.authenticated;
        final isUnknown = auth.status == AuthStatus.unknown;
        final path = state.matchedLocation;

        if (isUnknown) return null;
        if (path == '/splash') return null;

        final publicPaths = ['/login', '/register'];
        final isPublic = publicPaths.any((p) => path.startsWith(p));

        if (!isAuth && !isPublic) {
          if (path != '/login') return '/login';
        }

        return null;
      },
      refreshListenable: auth,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (_, __) => const RegisterScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomeScreen(),
            ),
            GoRoute(
              path: '/properties',
              builder: (_, __) => const PropertiesScreen(),
              routes: [
                GoRoute(
                  path: ':slug',
                  builder: (_, state) => PropertyDetailScreen(
                    slug: state.pathParameters['slug'] ?? '',
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/projects',
              builder: (_, __) => const ProjectsScreen(),
              routes: [
                GoRoute(
                  path: ':slug',
                  builder: (_, state) => ProjectDetailScreen(
                    slug: state.pathParameters['slug'] ?? '',
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/reservations',
              builder: (_, __) => const ReservationsScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/reserve/:propertyId',
          builder: (_, state) => CreateReservationScreen(
            propertyId: int.tryParse(state.pathParameters['propertyId'] ?? '0') ?? 0,
            propertyTitle: state.uri.queryParameters['title'] ?? '',
          ),
        ),
        GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/contact',
          builder: (_, __) => const ContactScreen(),
        ),
        GoRoute(
          path: '/page/:slug',
          builder: (_, state) => PageDetailScreen(
            slug: state.pathParameters['slug'] ?? '',
          ),
        ),
      ],
    );
  }
}
