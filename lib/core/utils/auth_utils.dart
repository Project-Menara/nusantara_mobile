import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthUtils {
  static const storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  static Future<void> removeToken() async {
    return await storage.delete(key: 'token');
  }

  static Future<void> setToken(String token) async {
    return await storage.write(key: 'token', value: token);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    return true;
  }
}
