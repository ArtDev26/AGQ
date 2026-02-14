import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/home/presentation/pages/brix_pre_cosecha.dart';

GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    // ✅ REDIRECT SEGÚN AUTH
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggingIn = state.matchedLocation == '/login';

      final isAuthed = authState is AuthAuthenticated;
      final isLoading = authState is AuthLoading;

      // Mientras carga, no redirigir (evita loops)
      if (isLoading) return null;

      // Si ya está autenticado y está en /login => mandarlo a /home
      if (isAuthed && isLoggingIn) return '/home';

      // Si NO está autenticado y quiere ir a otra ruta => mandarlo a /login
      if (!isAuthed && !isLoggingIn) return '/login';

      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MedicionBrixPreCosechaPage(),
      ),

      // Luego agregas:
      // GoRoute(path: '/evaluaciones', builder: ...),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
