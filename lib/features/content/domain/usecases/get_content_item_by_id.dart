import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_plus/core/errors/failure.dart';
import 'package:pocket_plus/core/usecases/usecase.dart';
import 'package:pocket_plus/features/content/domain/entities/content_item.dart';
import 'package:pocket_plus/features/content/domain/repositories/content_repository.dart';

class GetContentItemById implements UseCase<ContentItem, Params> {
  final ContentRepository repository;

  GetContentItemById(this.repository);

  @override
  Future<Either<Failure, ContentItem>> call(Params params) async {
    return await repository.getContentItemById(params.itemId);
  }
}

class Params extends Equatable {
  final String itemId;

  const Params({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}
