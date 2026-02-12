import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/pages/login_page.dart';

GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      // Luego agregamos /home, /evaluaciones, etc.
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
