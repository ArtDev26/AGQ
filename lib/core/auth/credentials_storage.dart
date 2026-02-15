import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CredentialsStorage {
  CredentialsStorage._();

  static const _kRememberedUsername = 'remembered_username';
  static const _kRememberedPassword = 'remembered_password';

  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  static Future<({String? username, String? password})> getRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_kRememberedUsername);

    final password = await _secure.read(key: _kRememberedPassword);

    return (
      username: username?.trim().isEmpty == true ? null : username?.trim(),
      password: (password?.isEmpty == true ? null : password),
    );
  }
}
