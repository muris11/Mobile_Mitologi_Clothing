class ApiConfig {
  ApiConfig._();

  static const String _apiBaseOverride = String.fromEnvironment(
    'MITOLOGI_API_BASE_URL',
    defaultValue: '',
  );

  static const String _storageBaseOverride = String.fromEnvironment(
    'MITOLOGI_STORAGE_BASE_URL',
    defaultValue: '',
  );

  static const String apiVersion = 'v1';
  static const int timeoutDuration = 30000;

  static String _normalizeBase(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;

  static const String _productionBaseUrl =
      'https://adminmitologiclothing.center.biz.id';

  static String get _defaultBackendOrigin {
    if (_apiBaseOverride.isNotEmpty) {
      return _apiBaseOverride;
    }
    return _productionBaseUrl;
  }

  static String get baseUrl {
    final base = _normalizeBase(_defaultBackendOrigin);
    return base.endsWith('/api/$apiVersion') ? base : '$base/api/$apiVersion';
  }

  static String get _rawBaseUrl => _normalizeBase(_defaultBackendOrigin);

  static String get storageUrl {
    final override = _normalizeBase(_storageBaseOverride.trim());
    return override.isNotEmpty ? override : _rawBaseUrl;
  }

  static String buildImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;

    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    if (normalizedPath.startsWith('storage/')) {
      return '$storageUrl/$normalizedPath';
    }
    return '$storageUrl/storage/$normalizedPath';
  }
}
