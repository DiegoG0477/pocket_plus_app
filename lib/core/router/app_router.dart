import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Para proveer AuthCubit
import 'package:get_it/get_it.dart'; // Para obtener AuthCubit de GetIt
import 'package:go_router/go_router.dart';
import 'package:pocket_plus/core/router/app_routes.dart';
import 'package:pocket_plus/features/auth/presentation/cubit/auth_cubit.dart'; // Importa AuthCubit
import 'dart:async'; // Importa StreamSubscription
import 'package:pocket_plus/features/content/presentation/pages/dashboard_page.dart'; // Importa DashboardPage
import 'package:pocket_plus/features/content/presentation/cubit/content_cubit.dart'; // Importa ContentCubit
import 'package:pocket_plus/features/auth/presentation/pages/login_page.dart'; // Importa LoginPage
import 'package:pocket_plus/features/auth/presentation/pages/register_page.dart'; // Importa RegisterPage
import 'package:pocket_plus/features/content/presentation/pages/content_detail_page.dart';
import 'package:pocket_plus/features/content/presentation/pages/add_content_page.dart';
import 'package:pocket_plus/features/overview/presentation/pages/overview_page.dart'; // Importar OverviewPage
import 'package:pocket_plus/features/profile/presentation/pages/profile_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.overview, // Esta es la ruta inicial
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.overview,
        name: AppRoutes.overview, // Puedes darle un nombre si quieres
        builder: (context, state) =>
            const OverviewPage(), // Aquí va la OverviewPage
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => BlocProvider.value(
          // Provee el AuthCubit
          value: GetIt.I<AuthCubit>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profile,
        builder: (context, state) =>
            const ProfilePage(), // BlocProvider está dentro de ProfilePage
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.register,
        builder: (context, state) => BlocProvider.value(
          // Provee el AuthCubit
          value: GetIt.I<AuthCubit>(),
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.dashboard,
        builder: (context, state) {
          return BlocProvider.value(
            value: GetIt.I<ContentCubit>(),
            child: const DashboardPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addContent,
        name: AppRoutes.addContent,
        builder: (context, state) => const AddContentPage(),
      ),
      GoRoute(
        path: AppRoutes.contentDetail,
        name: AppRoutes.contentDetail,
        builder: (context, state) {
          final itemId = state.pathParameters['id'];
          if (itemId == null) {
            // Si no hay ID, redirigir al dashboard
            return const DashboardPage();
          }
          return BlocProvider.value(
            value: GetIt.I<ContentCubit>(),
            child: ContentDetailPage(itemId: itemId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editContent,
        name: AppRoutes.editContent,
        builder: (context, state) {
          final itemId = state.pathParameters['id'];
          if (itemId == null) {
            // Si no hay ID, redirigir al dashboard
            return const DashboardPage();
          }
          return AddContentPage(itemId: itemId);
        },
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      print("--- 🚦 GO_ROUTER REDIRECT 🚦 ---");
      print("Ruta solicitada: ${state.matchedLocation}");

      final authCubit = GetIt.I<AuthCubit>();
      final authState = authCubit.state;
      print("Estado actual del AuthCubit: ${authState.runtimeType}");

      final bool loggedIn = authState is AuthSuccess;
      print("¿Considerado 'loggedIn'?: $loggedIn");

      final loggingInOrRegistering =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.overview;

      if (loggedIn && loggingInOrRegistering) {
        print(
          "Decisión: Logueado en página pública. Redirigiendo a ${AppRoutes.dashboard}",
        );
        return AppRoutes.dashboard;
      }

      if (!loggedIn && !loggingInOrRegistering) {
        print(
          "Decisión: NO logueado en página protegida. Redirigiendo a ${AppRoutes.login}",
        );
        return AppRoutes.login;
      }

      print("Decisión: Sin redirección (return null).");
      print("---------------------------------");
      return null; // No redirigir en otros casos
    },
    refreshListenable: GoRouterRefreshStream(
      GetIt.I<AuthCubit>().stream,
    ), // Escucha cambios en AuthCubit
  );
}

// Helper para que GoRouter reaccione a cambios de estado de BLoC/Cubit
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
