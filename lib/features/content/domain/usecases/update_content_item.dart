import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_plus/core/errors/failure.dart';
import 'package:pocket_plus/core/usecases/usecase.dart';
import 'package:pocket_plus/features/content/domain/entities/content_item.dart';
import 'package:pocket_plus/features/content/domain/repositories/content_repository.dart';
import 'dart:io'; // Import for File

class UpdateContentItem implements UseCase<ContentItem, UpdateContentItemParams> {
  final ContentRepository repository;

  UpdateContentItem(this.repository);

  @override
  Future<Either<Failure, ContentItem>> call(UpdateContentItemParams params) async {
    if (params.contentItem.titulo.isEmpty) {
      return Left(InvalidInputFailure('El título del elemento de contenido no puede estar vacío.'));
    }
    return await repository.updateContentItem(
      params.contentItem,
      imageFile: params.imageFile,
      removeCurrentImage: params.removeCurrentImage,
    );
  }
}

class UpdateContentItemParams extends Equatable {
  final ContentItem contentItem;
  final File? imageFile;
  final bool removeCurrentImage;

  const UpdateContentItemParams({
    required this.contentItem,
    this.imageFile,
    this.removeCurrentImage = false,
  });

  @override
  List<Object?> get props => [contentItem, imageFile, removeCurrentImage];
}

class InvalidInputFailure extends Failure {
  final String message;

  InvalidInputFailure(this.message) : super(message);

  @override
  List<Object> get props => [message];
}
