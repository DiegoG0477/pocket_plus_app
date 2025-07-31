import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_plus/core/errors/failure.dart';
import 'package:pocket_plus/core/usecases/usecase.dart';
import 'package:pocket_plus/features/content/domain/entities/content_item.dart';
import 'package:pocket_plus/features/content/domain/repositories/content_repository.dart';
import 'dart:io'; // Import for File

class AddContentItem implements UseCase<ContentItem, AddContentItemParams> {
  final ContentRepository repository;

  AddContentItem(this.repository);

  @override
  Future<Either<Failure, ContentItem>> call(AddContentItemParams params) async {
    return await repository.addContentItem(
      params.contentItem,
      imageFile: params.imageFile,
    );
  }
}

class AddContentItemParams extends Equatable {
  final ContentItem contentItem;
  final File? imageFile;

  const AddContentItemParams({required this.contentItem, this.imageFile});

  @override
  List<Object?> get props => [contentItem, imageFile];
}

class InvalidInputFailure extends Failure {
  final String message;

  InvalidInputFailure(this.message) : super(message);

  @override
  List<Object> get props => [message];
}
