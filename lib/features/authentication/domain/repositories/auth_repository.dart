// Kontrak/Blueprint untuk repository
abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> loginWithGoogle();
}