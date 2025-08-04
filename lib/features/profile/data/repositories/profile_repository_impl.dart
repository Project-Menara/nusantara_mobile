import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';
// <<< PERBAIKAN: Pastikan UserEntity diimpor dari 'authentication' >>>
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:nusantara_mobile/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource profileRemoteDataSource;
  final LocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.profileRemoteDataSource,
    required this.networkInfo,
    required this.localDatasource,
  });

  // <<< PERBAIKAN UTAMA ADA DI SINI >>>
  @override
  Future<Either<Failures, UserEntity>> updateUserProfile(
    UserEntity user,
    File? photoFile,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final token = await localDatasource.getAuthToken();
        if (token == null) {
          return const Left(
            AuthFailure('Sesi tidak valid, silakan login kembali.'),
          );
        }

        final userModel = UserModel.fromEntity(user);
        final result = await profileRemoteDataSource.updateUserProfile(
          user: userModel,
          photoFile: photoFile,
          token: token,
        );
        return Right(result as UserEntity);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('Tidak ada koneksi internet'));
    }
  }

  @override
  Future<Either<Failures, void>> createNewPin(String newPin) async {
    if (await networkInfo.isConnected) {
      try {
        final token = await localDatasource.getAuthToken();
        if (token == null) return const Left(AuthFailure('Session expired.'));

        await profileRemoteDataSource.createNewPin(
          newPin: newPin,
          token: token,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  // <<< BARU: Implementasi repository untuk konfirmasi PIN baru >>>
  @override
  Future<Either<Failures, UserEntity>> confirmNewPin(String confirmPin) async {
    if (await networkInfo.isConnected) {
      try {
        final token = await localDatasource.getAuthToken();
        if (token == null) return const Left(AuthFailure('Session expired.'));

        final result = await profileRemoteDataSource.confirmNewPin(
          confirmPin: confirmPin,
          token: token,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, void>> requestChangePhone(String newPhone) async {
    if (await networkInfo.isConnected) {
      try {
        final token = await localDatasource.getAuthToken();
        if (token == null) return const Left(AuthFailure('Session expired.'));

        await profileRemoteDataSource.requestChangePhone(
          newPhone: newPhone,
          token: token,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  // <<< BARU: Implementasi repository untuk verifikasi OTP ganti nomor telepon >>>
  @override
  Future<Either<Failures, void>> verifyChangePhone({
    required String phone,
    required String code,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final token = await localDatasource.getAuthToken();
        if (token == null) return const Left(AuthFailure('Session expired.'));

        await profileRemoteDataSource.verifyChangePhone(
          phone: phone,
          code: code,
          token: token,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, void>> logoutUser() async {
    if (await networkInfo.isConnected) {
      try {
        final token = await localDatasource.getAuthToken();
        await profileRemoteDataSource.logoutUser(token!);
        await localDatasource.clearAuthToken();
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }
}
