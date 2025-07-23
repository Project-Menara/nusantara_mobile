import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';


abstract class AuthRepository{
  Future<Either<Failures, User>> login(String username, String password);
  Future<Either<Failures, User>> register(
    String name,
    String username,
    String email,
    String password,
    String confirmationPassword,
  );
  Future<Either<Failures, User>> getUser(String token);
  Future<Either<Failures, String>> logout(String token);
}