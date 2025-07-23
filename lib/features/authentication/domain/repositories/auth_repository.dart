// Kontrak/Blueprint untuk repository
abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> loginWithGoogle();

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String gender,
  });
}