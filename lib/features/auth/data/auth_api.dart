import 'package:http/http.dart' as http;

class AuthApi {
  static const String _baseUrl =
      'https://agkwebagro.agrokasa.pe/WSRESTMovilidadERP';

  Future<String> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/api/login/authenticate');

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
