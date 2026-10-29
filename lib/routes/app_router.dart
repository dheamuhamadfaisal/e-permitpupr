import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/navigation/access_denied_screen.dart';
import '../features/navigation/admin_navigation.dart';
import '../features/navigation/operator_navigation.dart';
import '../features/navigation/pemohon_navigation.dart';
import '../features/navigation/petugas_navigation.dart';
import '../features/notification/screens/notification_screen.dart';
import '../features/operator/screens/operator_detail_screen.dart';
import '../features/pemohon/screens/create_permohonan_screen.dart';
import '../features/pemohon/screens/detail_permohonan_screen.dart';
import '../features/pemohon/screens/permohonan_list_screen.dart';
import '../models/permohonan_model.dart';
import '../features/petugas/screens/petugas_detail_screen.dart';
import '../features/profile/screens/change_password_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/admin/screens/admin_detail_screen.dart';
import '../features/verifikator/screens/verifikasi_detail_screen.dart';
import '../providers/auth_provider.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';

  static const String permohonanList = '/permohonan';
  static const String createPermohonan = '/permohonan/create';
  static const String notification = '/notification';
}

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final authStatus = authProvider.status;
        final currentPath = state.uri.path;

        if (authStatus == AuthStatus.checking) {
          if (currentPath != AppRoutes.splash) {
            return AppRoutes.splash;
          }
          return null;
        }

        if (authStatus == AuthStatus.unauthenticated) {
          if (currentPath == AppRoutes.login || currentPath == AppRoutes.register) {
            return null;
          }
          return AppRoutes.login;
        }

        if (authStatus == AuthStatus.authenticated) {
          if (currentPath == AppRoutes.login ||
              currentPath == AppRoutes.register ||
              currentPath == AppRoutes.splash) {
            return AppRoutes.home;
          }
          return null;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Role-Based Home Switcher
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) {
            final user = authProvider.user;
            final roleSlug = user?.primaryRoleSlug;

            switch (roleSlug) {
              case 'pemohon':
                return const PemohonNavigation();
              case 'operator':
                return const OperatorNavigation();
              case 'petugas':
                return const PetugasNavigation();
              case 'admin':
                return const AdminNavigation();
              default:
                return const AccessDeniedScreen();
            }
          },
        ),

        // Profile Routes
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.editProfile,
          name: 'editProfile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.changePassword,
          name: 'changePassword',
          builder: (context, state) => const ChangePasswordScreen(),
        ),

        // Notification Route
        GoRoute(
          path: AppRoutes.notification,
          name: 'notification',
          builder: (context, state) => const NotificationScreen(),
        ),

        // Pemohon Routes
        GoRoute(
          path: AppRoutes.permohonanList,
          name: 'permohonanList',
          builder: (context, state) => const PermohonanListScreen(),
        ),
        GoRoute(
          path: AppRoutes.createPermohonan,
          name: 'createPermohonan',
          builder: (context, state) {
            final kode = state.uri.queryParameters['kode'];
            return CreatePermohonanScreen(initialKode: kode);
          },
        ),
        GoRoute(
          path: '/permohonan/:id',
          name: 'permohonanDetail',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return DetailPermohonanScreen(permohonanId: id);
          },
        ),
        GoRoute(
          path: '/permohonan/:id/edit',
          name: 'editPermohonan',
          builder: (context, state) {
            final draft = state.extra as PermohonanModel?;
            return CreatePermohonanScreen(draft: draft);
          },
        ),

        // Operator Routes
        GoRoute(
          path: '/operator/permohonan/:id',
          name: 'operatorDetail',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return OperatorDetailScreen(permohonanId: id);
          },
        ),

        // Petugas Routes
        GoRoute(
          path: '/petugas/permohonan/:id',
          name: 'petugasDetail',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return PetugasDetailScreen(permohonanId: id);
          },
        ),

        // Verifikator Routes
        GoRoute(
          path: '/verifikator/permohonan/:id',
          name: 'verifikatorDetail',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return VerifikasiDetailScreen(permohonanId: id);
          },
        ),


        // Admin Routes
        GoRoute(
          path: '/admin/monitoring/:id',
          name: 'adminDetail',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return AdminDetailScreen(permohonanId: id);
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Halaman tidak ditemukan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
