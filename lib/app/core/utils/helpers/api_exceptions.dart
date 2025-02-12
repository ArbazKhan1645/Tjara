class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? response;

  ApiException(this.message, {this.statusCode, this.response});

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}