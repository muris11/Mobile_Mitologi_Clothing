class ResponseNormalizer {
  ResponseNormalizer._();

  static dynamic normalize(dynamic response) {
    final extracted = _extractEnvelope(response);
    return _normalizeValue(extracted);
  }

  static dynamic _extractEnvelope(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  static dynamic _normalizeValue(dynamic value) {
    if (value is List) {
      return value.map(_normalizeValue).toList();
    }

    if (value is Map) {
      final normalized = <String, dynamic>{};
      for (final entry in value.entries) {
        final key = entry.key.toString();
        normalized[_toCamelCase(key)] = _normalizeValue(entry.value);
      }
      return normalized;
    }

    return value;
  }

  static String _toCamelCase(String key) {
    return key.replaceAllMapped(RegExp(r'_([a-zA-Z0-9])'), (match) {
      return match.group(1)!.toUpperCase();
    });
  }
}
