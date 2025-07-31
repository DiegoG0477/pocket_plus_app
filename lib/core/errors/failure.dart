import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode; // Opcional, para errores de servidor

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(String message, {int? statusCode}) : super(message, statusCode: statusCode);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure(String message) : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(String message) : super(message, statusCode: 401);
}