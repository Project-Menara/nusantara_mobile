// lib/features/authentication/data/repositories/auth_repository_impl.dart

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

  // --- PERBAIKAN: _getResponse sekarang bisa mengenali AuthErrorType ---
  Future<Either<Failures, T>> _getResponse<T>(Future<T> Function() call) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await call();
        return Right(result);
      } on AuthException catch (e) {
        // Jika exception adalah tipe token expired, kembalikan Failure yang spesifik
        if (e.type == AuthErrorType.tokenExpired) {
          return Left(TokenExpiredFailure(e.message));
        }
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
  
  // <<< TAMBAHAN IMPLEMENTASI VALIDASI TOKEN >>>
  @override
  Future<Either<Failures, void>> validateForgotPinToken(String token) async {
    return _getResponse(() => authRemoteDatasource.validateForgotPinToken(token));
  }

  @override
  Future<Either<Failures, void>> setNewPinForgot({
    required String token,
    required String phoneNumber,
    required String pin,
  }) async {
    // --- PERBAIKAN: Gunakan _getResponse agar lebih bersih dan konsisten ---
    return _getResponse(() => authRemoteDatasource.setNewPinForgot(
      token: token,
      phoneNumber: phoneNumber,
      pin: pin,
    ));
  }

  @override
  Future<Either<Failures, UserEntity>> confirmNewPinForgot({
    required String token,
    required String phoneNumber,
    required String confirmPin,
  }) async {
    // --- PERBAIKAN: Gunakan _getResponse agar lebih bersih dan konsisten ---
    return _getResponse(() async {
      final userModel = await authRemoteDatasource.confirmNewPinForgot(
        token: token,
        phoneNumber: phoneNumber,
        confirmPin: confirmPin,
      );
      await localDatasource.cacheAuthToken(userModel.token!);
      return userModel;
    });
  }

  @override
  Future<Either<Failures, PhoneCheckEntity>> checkPhone(
    String phoneNumber,
  ) async {
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
    return _getResponse(() async {
      final userModel = await authRemoteDatasource.confirmPin(
        phone: phone,
        confirmPin: confirmPin,
      );
      await localDatasource.cacheAuthToken(userModel.token!);
      return userModel;
    });
  }

  @override
  Future<Either<Failures, UserEntity>> verifyPinAndLogin({
    required String phoneNumber,
    required String pin,
  }) async {
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
    try {
      final token = await localDatasource.getAuthToken();
      if (token == null) {
        return const Left(AuthFailure('No token found'));
      }

      if (await networkInfo.isConnected) {
        final user = await authRemoteDatasource.getUserProfile(token: token);
        return Right(user);
      } else {
        return const Left(
          NetworkFailure('No Internet Connection to fetch profile'),
        );
      }
    } on AuthException catch (e) {
      // --- PERBAIKAN: Tangani juga token expired di sini ---
      if (e.type == AuthErrorType.tokenExpired) {
        return Left(TokenExpiredFailure(e.message));
      }
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
  Future<Either<Failures, String>> forgotPin(String phoneNumber) async {
    return _getResponse(() {
      return authRemoteDatasource.forgotPin(phoneNumber);
    });
  }

  @override
  Future<Either<Failures, Unit>> logout() async {
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