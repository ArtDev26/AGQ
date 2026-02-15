import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  /// Base URL editable (por ahora en memoria).
  static final ValueNotifier<String> baseUrl = ValueNotifier<String>(
    'https:..',
    //'https://agkwebagro.agrokasa.pe/WSRESTMovilidadERPPruebas',
  );

  static String get currentBaseUrl => baseUrl.value.trim();
}
