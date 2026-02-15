import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  ApiConfig._();

  static const String _kBaseUrl = 'api_base_url';

  //  Base URL por defecto (si aún no guardaste nada)
  static const String _defaultBaseUrl = 'https:..';
  // Ejemplo real:
  //   'https://agkwebagro.agrokasa.pe/WSRESTMovilidadERPPruebas';

  /// Base URL en memoria (para que la UI reaccione si cambia)
  static final ValueNotifier<String> baseUrl = ValueNotifier<String>(
    _defaultBaseUrl,
  );

  static String get currentBaseUrl => baseUrl.value.trim();

  ///  Carga desde SharedPreferences (persistente)
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kBaseUrl);

    if (saved != null && saved.trim().isNotEmpty) {
      baseUrl.value = saved.trim();
    } else {
      baseUrl.value = _defaultBaseUrl;
    }
  }

  ///  Guarda en SharedPreferences y actualiza en memoria
  static Future<void> save(String url) async {
    final v = url.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBaseUrl, v);
    baseUrl.value = v;
  }

  /// (Opcional) borrar y volver al default
  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kBaseUrl);
    baseUrl.value = _defaultBaseUrl;
  }
}
