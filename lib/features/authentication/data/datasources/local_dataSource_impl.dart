import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String authTokenKey = "authToken";
const String roleKey = "role";

class LocalDatasourceImpl implements LocalDatasource {
  final SharedPreferences sharedPreferences;

  LocalDatasourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheAuthToken(String token) {
    return sharedPreferences.setString(authTokenKey, token);
  }

  @override
  Future<void> clearAuthToken() {
    return sharedPreferences.remove(authTokenKey);
  }

  @override
  Future<String?> getAuthToken() {
    return Future.value(sharedPreferences.getString(authTokenKey));
  }

  @override
  Future<void> saveRole(String role) {
    return sharedPreferences.setString(roleKey, role);
  }

  @override
  Future<String?> getRole() {
    return Future.value(sharedPreferences.getString(roleKey));
  }

  @override
  Future<void> clearRole() {
    return sharedPreferences.remove(roleKey);
  }
}
