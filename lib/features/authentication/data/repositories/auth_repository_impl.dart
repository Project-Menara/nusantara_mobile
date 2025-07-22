import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> login(String email, String password) async {
    // Memanggil datasource untuk berinteraksi dengan API
    return await remoteDataSource.login(email, password);
  }
  
  @override
  Future<void> loginWithGoogle() async {
    // Logika untuk login dengan Google
    return await remoteDataSource.loginWithGoogle();
  }
}