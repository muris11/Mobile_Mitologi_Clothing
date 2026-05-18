class ApiResponse<T> {
  final bool status;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      meta: json['meta'] is Map ? Map<String, dynamic>.from(json['meta'] as Map) : null,
    );
  }
}
