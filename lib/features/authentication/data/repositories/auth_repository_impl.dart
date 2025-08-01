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

  // BARU: Helper method terpusat untuk menangani semua request ke remote data source
  Future<Either<Failures, T>> _getResponse<T>(Future<T> Function() call) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await call();
        return Right(result);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on RateLimitException catch (e) {
        return Left(RateLimitFailure(e.message, e.retryAfterSeconds));
      }
    } else {
      return const Left(NetworkFailure('Tidak ada koneksi internet'));
    }
  }

  @override
  Future<Either<Failures, PhoneCheckEntity>> checkPhone(
    String phoneNumber,
  ) async {
    // REFACTOR: Jadi lebih ringkas
    return _getResponse(() async {
      final resultModel = await authRemoteDatasource.checkPhone(phoneNumber);
      return resultModel.toEntity();
    });
  }

  @override
  Future<Either<Failures, Unit>> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
    // REFACTOR: Jadi lebih ringkas
    return _getResponse(() async {
      await authRemoteDatasource.verifyCode(
        phoneNumber: phoneNumber,
        code: code,
      );
      return unit;
    });
  }

  @override
  Future<Either<Failures, RegisterResponseModel>> register(
    RegisterEntity user,
  ) async {
    // REFACTOR: Jadi lebih ringkas
    return _getResponse(() {
      final formModel = RegisterModel.fromEntity(user);
      return authRemoteDatasource.register(formModel);
    });
  }

  @override
  Future<Either<Failures, Unit>> createPin({
    required String phoneNumber,
    required String pin,
  }) async {
    // REFACTOR: Jadi lebih ringkas
    return _getResponse(() async {
      await authRemoteDatasource.createPin(phoneNumber: phoneNumber, pin: pin);
      return unit;
    });
  }

  @override
  Future<Either<Failures, UserEntity>> confirmPin({
    required String phone,
    required String confirmPin,
  }) async {
    // REFACTOR: Jadi lebih ringkas
    return _getResponse(() {
      return authRemoteDatasource.confirmPin(
        phone: phone,
        confirmPin: confirmPin,
      );
    });
  }

  @override
  Future<Either<Failures, UserEntity>> verifyPinAndLogin({
    required String phoneNumber,
    required String pin,
  }) async {
    // REFACTOR: Jadi lebih ringkas
    return _getResponse(() async {
      final token = await authRemoteDatasource.loginAndGetToken(
        phoneNumber: phoneNumber,
        pin: pin,
      );
      await localDatasource.cacheAuthToken(token);
      final user = await authRemoteDatasource.getUserProfile(token: token);
      return user;
    });
  }

  @override
  Future<Either<Failures, UserEntity>> getLoggedInUser() async {
    // Metode ini berbeda karena tidak selalu butuh koneksi internet di awal,
    // jadi biarkan seperti ini agar logikanya tetap jelas.
    try {
      final token = await localDatasource.getAuthToken();
      if (token == null) {
        return const Left(AuthFailure('No token found'));
      }

      // Jika ada token, coba ambil profil user (butuh internet)
      if (await networkInfo.isConnected) {
        final user = await authRemoteDatasource.getUserProfile(token: token);
        return Right(user);
      } else {
        // Opsional: Jika offline, Anda bisa coba ambil data user dari cache jika ada
        return const Left(
          NetworkFailure('No Internet Connection to fetch profile'),
        );
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, Unit>> resendCode(String phoneNumber) async {
    return _getResponse(() async {
      await authRemoteDatasource.resendCode(phoneNumber);
      return unit;
    });
  }

  @override
  Future<Either<Failures, Unit>> logout() async {
    // REFACTOR: Jadi lebih ringkas
    return _getResponse(() async {
      final token = await localDatasource.getAuthToken();
      if (token != null) {
        await authRemoteDatasource.logout(token);
        await localDatasource.clearAuthToken();
      }
      return unit;
    });
  }
}
