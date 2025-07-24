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
        return Right(resultModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        // Menambahkan catch-all untuk error yang tidak terduga
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

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
        // PENTING: Simpan token dan role ke local storage setelah login berhasil
        await localDatasource.cacheAuthToken(userModel.token);
        // Asumsi UserModel memiliki properti 'role', sesuaikan jika namanya berbeda
        // await localDatasource.saveRole(userModel.role);
        return Right(userModel);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        // Menambahkan catch-all untuk error yang tidak terduga
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, Unit>> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String gender,
    required String pin,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await authRemoteDatasource.register(
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          gender: gender,
          pin: pin,
        );
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        // Menambahkan catch-all untuk error yang tidak terduga
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, Unit>> logout() async {
    if (await networkInfo.isConnected) {
      try {
        final token = await localDatasource.getAuthToken();
        if (token == null) return const Right(unit);

        await authRemoteDatasource.logout(token);
        await localDatasource.clearAuthToken();
        // Hapus juga role jika ada
        // await localDatasource.clearRole();
        return const Right(unit);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
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
