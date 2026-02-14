import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';

class AuthApi {
  Future<String> login({
    required String username,
    required String password,
  }) async {
    final base = ApiConfig.currentBaseUrl;

    final url = Uri.parse('$base/api/login/authenticate');

    final response = await http.post(
      url,
      headers: {
        'accept': 'application/json',
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) return response.body;
      throw Exception('Token vacío');
    }

    throw Exception('Error login: ${response.statusCode} - ${response.body}');
  }
}
