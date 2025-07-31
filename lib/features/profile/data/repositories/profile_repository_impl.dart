import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:nusantara_mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:nusantara_mobile/features/profile/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  final ProfileRemoteDataSource profileRemoteDataSource;
  final LocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.profileRemoteDataSource,
    required this.networkInfo,
    required this.localDatasource,
  });

  @override
  Future<Either<Failures, List<UserEntity>>> getUserProfiles() async {
    if (await networkInfo.isConnected) {
      try {
        final token = await localDatasource.getAuthToken();
        final userModels = await profileRemoteDataSource.getUserProfiles(
          token!,
        );
        final users = userModels.map((model) => model as UserEntity).toList();
        return Right(users);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, UserEntity>> updateUserProfile(UserEntity user) {
    // TODO: implement updateUserProfile
    throw UnimplementedError();
  }
}
