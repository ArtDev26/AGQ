import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/agp_app.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/presentation/pages/brix_pre_cosecha.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>(create: (_) => AuthBloc())],
      child: const AgqApp(),
    ),
  );
}
