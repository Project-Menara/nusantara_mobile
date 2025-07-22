// Berinteraksi langsung dengan API (menggunakan http atau dio)
import 'package:http/http.dart' as http;

abstract class AuthRemoteDataSource {
  Future<void> login(String email, String password);
  Future<void> loginWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<void> login(String email, String password) async {
    // final response = await client.post(
    //   Uri.parse('https://your.api/login'),
    //   body: {'email': email, 'password': password},
    // );
    // Proses response...
    print('Login attempt with $email');
    await Future.delayed(const Duration(seconds: 1)); // Simulasi network call
  }

  @override
  Future<void> loginWithGoogle() async {
    // Implementasi login Google Firebase/OAuth
    print('Login with Google attempt');
    await Future.delayed(const Duration(seconds: 1));
  }
}