import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/voucher_entity.dart';
import 'package:nusantara_mobile/features/voucher/domain/repositories/voucher_repository.dart';

class GetVoucherByIdUsecase implements Usecase<VoucherEntity, DetailParams> {
  final VoucherRepository voucherRepository;

  GetVoucherByIdUsecase(this.voucherRepository);

  @override
  Future<Either<Failures, VoucherEntity>> call(DetailParams params) async {
    return await voucherRepository.getVoucherById(params.id);
  }
}

class DetailParams extends Equatable {
  final String id;

  const DetailParams({required this.id});
  @override
  List<Object?> get props => [id];
}