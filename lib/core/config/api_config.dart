import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  /// Base URL
  static final ValueNotifier<String> baseUrl = ValueNotifier<String>(
    'https://agkwebagro.agrokasa.pe/WSRESTMovilidadERPPruebas',
  );

  static String get currentBaseUrl => baseUrl.value.trim();
}
