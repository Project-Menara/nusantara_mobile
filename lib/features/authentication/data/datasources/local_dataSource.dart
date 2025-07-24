abstract class LocalDatasource {
  Future<void> cacheAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> clearAuthToken();
  Future<void> saveRole(String role);
  Future<String?> getRole();
  Future<void> clearRole();
}
