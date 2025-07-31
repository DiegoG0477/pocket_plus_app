class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data; // Para el cuerpo del error de la API

  ServerException(this.message, {this.statusCode, this.data});

  @override
  String toString() {
    return 'ServerException: $message (StatusCode: $statusCode, Data: $data)';
  }
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);

  @override
  String toString() {
    return 'UnauthorizedException: $message';
  }
}
