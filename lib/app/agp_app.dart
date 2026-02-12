import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'routes.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

class AgqApp extends StatelessWidget {
  const AgqApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AGQ',
      routerConfig: buildRouter(authBloc),
    );
  }
}
