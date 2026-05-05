class ParserUtils {
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is num) return value.toInt();
    return defaultValue;
  }

  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    if (value is num) return value.toDouble();
    return defaultValue;
  }

  static bool parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lowercase = value.toLowerCase();
      if (lowercase == 'true' || lowercase == '1') return true;
      if (lowercase == 'false' || lowercase == '0') return false;
    }
    return defaultValue;
  }

  static List<T> parseList<T>(
      dynamic value, T Function(Map<String, dynamic>) mapper) {
    if (value == null || value is! List) return [];

    final List<T> result = [];
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        try {
          result.add(mapper(item));
        } catch (_) {}
      }
    }
    return result;
  }

  static Map<String, dynamic> parseMap(dynamic value) {
    if (value == null || value is! Map) return {};
    return Map<String, dynamic>.from(value);
  }
}
