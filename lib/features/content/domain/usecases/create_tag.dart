import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_plus/core/errors/failure.dart';
import 'package:pocket_plus/core/usecases/usecase.dart';
import 'package:pocket_plus/features/content/domain/entities/tag.dart';
import 'package:pocket_plus/features/content/domain/repositories/content_repository.dart';

class CreateTag implements UseCase<Tag, CreateTagParams> {
  final ContentRepository repository;

  CreateTag(this.repository);

  @override
  Future<Either<Failure, Tag>> call(CreateTagParams params) async {
    if (params.name.isEmpty) {
      return Left(InvalidInputFailure('El nombre del tag no puede estar vacío.'));
    }
    return await repository.createTag(params.name, params.userId);
  }
}

class CreateTagParams extends Equatable {
  final String name;
  final String userId;

  const CreateTagParams({required this.name, required this.userId});

  @override
  List<Object?> get props => [name, userId];
}

class InvalidInputFailure extends Failure {
  final String message;

  InvalidInputFailure(this.message) : super(message);

  @override
  List<Object> get props => [message];
}
