import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_plus/core/errors/failure.dart';
import 'package:pocket_plus/core/usecases/usecase.dart';
import 'package:pocket_plus/features/content/domain/entities/tag.dart';
import 'package:pocket_plus/features/content/domain/repositories/content_repository.dart';

class GetUserTags implements UseCase<List<Tag>, GetUserTagsParams> {
  final ContentRepository repository;

  GetUserTags(this.repository);

  @override
  Future<Either<Failure, List<Tag>>> call(GetUserTagsParams params) async {
    return await repository.getUserTags(params.userId);
  }
}

class GetUserTagsParams extends Equatable {
  final String userId;

  const GetUserTagsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
