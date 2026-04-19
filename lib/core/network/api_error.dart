class ApiError implements Exception {
  final String message;
  final int statusCode;
  final String? code;
  final Map<String, List<String>>? fieldErrors;

  const ApiError({
    required this.message,
    required this.statusCode,
    this.code,
    this.fieldErrors,
  });

  factory ApiError.network(String message) {
    return ApiError(message: message, statusCode: 0);
  }

  bool get isValidationError => statusCode == 422;
  bool get isAuthError => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isNetworkError => statusCode == 0;

  String? firstFieldError(String field) {
    final errors = fieldErrors?[field];
    if (errors == null || errors.isEmpty) return null;
    return errors.first;
  }

  @override
  String toString() => 'ApiError: $message (Status: $statusCode)';
}
