import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/phone_check_entity.dart';
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

  // PENAMBAHAN: Implementasi verifyCode
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
  Future<Either<Failures, Unit>> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String gender,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await authRemoteDatasource.register(
          name: name,
          username: username,
          email: email,
          phone: phone,
          gender: gender,
        );
        return const Right(unit);
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

  // PENAMBAHAN: Implementasi verifyPinAndLogin (sebelumnya di-comment)
  @override
  Future<Either<Failures, UserEntity>> verifyPinAndLogin({
    required String phoneNumber,
    required String pin,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await authRemoteDatasource.verifyPin(
          phoneNumber: phoneNumber,
          pin: pin,
        );
        // Anda mungkin perlu menyimpan token atau data sesi di sini
        // await localDatasource.cacheAuthToken(userModel.token);
        return Right(userModel);
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
