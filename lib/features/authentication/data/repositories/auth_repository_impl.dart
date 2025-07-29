import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:nusantara_mobile/features/authentication/data/models/register_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/register_response_model.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/phone_check_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/register_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDatasource;
  final LocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.authRemoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, PhoneCheckEntity>> checkPhone(
    String phoneNumber,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final resultModel = await authRemoteDatasource.checkPhone(phoneNumber);
        // Diasumsikan PhoneCheckResponseModel memiliki method toEntity()
        return Right(resultModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, Unit>> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await authRemoteDatasource.verifyCode(
          phoneNumber: phoneNumber,
          code: code,
        );
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, RegisterResponseModel>> register(
    RegisterEntity user,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final formEntity = RegisterModel.fromEntity(user);
        final created = await authRemoteDatasource.register(formEntity);
        return Right(created);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  // PENAMBAHAN: Implementasi createPin
  @override
  Future<Either<Failures, Unit>> createPin({
    required String phoneNumber,
    required String pin,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await authRemoteDatasource.createPin(
          phoneNumber: phoneNumber,
          pin: pin,
        );
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, Unit>> confirmPin({
    required String phone,
    required String confirmPin,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await authRemoteDatasource.confirmPin(
          phone: phone,
          confirmPin: confirmPin,
        );
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  // PENAMBAHAN: Implementasi verifyPinAndLogin (sebelumnya di-comment)
  @override
  Future<Either<Failures, UserEntity>> verifyPinAndLogin({
    required String phoneNumber,
    required String pin,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Langkah 1: Panggil API login untuk dapat TOKEN
        final String token = await authRemoteDatasource.loginAndGetToken(
          phoneNumber: phoneNumber,
          pin: pin,
        );
        await localDatasource.cacheAuthToken(token);

        // Langkah 2: Panggil API profil untuk dapat DATA USER LENGKAP
        final userModel = await authRemoteDatasource.getUserProfile(
          token: token,
        );

        return Right(userModel);
      } on RateLimitException catch (e) {
        return Left(RateLimitFailure(e.message, e.retryAfterSeconds));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, UserEntity>> getLoggedInUser() async {
    try {
      final token = await localDatasource.getAuthToken();
      if (token == null) {
        return const Left(AuthFailure('No token found'));
      }
      // Jika ada token, ambil profil user
      final user = await authRemoteDatasource.getUserProfile(token: token);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, Unit>> logout() async {
    // Implementasi logout tetap sama
    if (await networkInfo.isConnected) {
      try {
        final token = await localDatasource.getAuthToken();
        if (token == null) return const Right(unit);
        await authRemoteDatasource.logout(token);
        await localDatasource.clearAuthToken();
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on CacheException {
        return const Right(unit);
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }
}
