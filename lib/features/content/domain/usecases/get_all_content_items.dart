import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_plus/core/errors/failure.dart';
import 'package:pocket_plus/core/usecases/usecase.dart';
import 'package:pocket_plus/features/content/domain/entities/content_item.dart';
import 'package:pocket_plus/features/content/domain/entities/tag.dart'; // Assuming Tag is needed for filters
import 'package:pocket_plus/core/constants/content_types.dart'; // Para ContentTypeGeneral
import 'package:pocket_plus/features/content/domain/repositories/content_repository.dart';

class GetAllContentItems implements UseCase<List<ContentItem>, GetAllContentItemsParams> {
  final ContentRepository repository;

  GetAllContentItems(this.repository);

  @override
  Future<Either<Failure, List<ContentItem>>> call(GetAllContentItemsParams params) async {
    return await repository.getAllContentItems(
      params.userId,
      filterByStatus: params.filterByStatus,
      filterByType: params.filterByType,
      filterByPriority: params.filterByPriority,
      filterByTagId: params.filterByTagId,
    );
  }
}

class GetAllContentItemsParams extends Equatable {
  final String userId;
  final ContentStatus? filterByStatus;
  final ContentTypeGeneral? filterByType;
  final ContentPriority? filterByPriority;
  final String? filterByTagId;

  const GetAllContentItemsParams({
    required this.userId,
    this.filterByStatus,
    this.filterByType,
    this.filterByPriority,
    this.filterByTagId,
  });

  @override
  List<Object?> get props => [
        userId,
        filterByStatus,
        filterByType,
        filterByPriority,
        filterByTagId,
      ];
}
