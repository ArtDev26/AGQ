import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/agp_app.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => AuthBloc())],
      child: const AgqApp(),
    ),
  );
}
