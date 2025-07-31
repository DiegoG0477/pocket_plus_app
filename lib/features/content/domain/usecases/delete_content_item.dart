import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_plus/core/errors/failure.dart';
import 'package:pocket_plus/core/usecases/usecase.dart';
import 'package:pocket_plus/features/content/domain/repositories/content_repository.dart';

class DeleteContentItem implements UseCase<void, DeleteContentItemParams> {
  final ContentRepository repository;

  DeleteContentItem(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteContentItemParams params) async {
    return await repository.deleteContentItem(params.itemId);
  }
}

class DeleteContentItemParams extends Equatable {
  final String itemId;

  const DeleteContentItemParams({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}
