import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../auth/data/auth_api.dart';

class BrixApi {
  final AuthApi _authApi = AuthApi();

  String _cleanToken(String raw) {
    var t = raw.trim();

    if (t.startsWith('"') && t.endsWith('"') && t.length >= 2) {
      t = t.substring(1, t.length - 1);
    }
    return t;
  }

  Future<void> ejecutarSpGuardarBrix({
    required String username,
    required String password,
    required String nombreSp,
    required String entidadMapear,
    required Map<String, dynamic> payloadJson,
  }) async {
    final base = ApiConfig.currentBaseUrl;

    // Obtener token
    final rawToken = await _authApi.login(
      username: username,
      password: password,
    );
    final token = _cleanToken(rawToken);

    final url = Uri.parse('$base/api/EjecutarSPERP');

    final body = jsonEncode({
      'NombreSP': nombreSp,
      'EntidadMapear': entidadMapear,
      'TipoRespuesta': 0,
      'Parametros': [
        {'NombreParametro': 'Json', 'Valor': jsonEncode(payloadJson)},
      ],
    });

    final resp = await http
        .post(
          url,
          headers: {
            'accept': 'application/json',
            'content-type': 'application/json',
            'username': username,
            'password': password,
            'Authorization': 'Bearer $token',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 40));

    if (resp.statusCode == 200) return;

    throw Exception('EjecutarSPERP ${resp.statusCode}: ${resp.body}');
  }
}
