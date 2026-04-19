import '../config/api_config.dart';

/// Image model
class ImageModel {
  final String url;
  final String? altText;
  final int? width;
  final int? height;

  ImageModel({required this.url, this.altText, this.width, this.height});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['url']?.toString() ?? json['src']?.toString() ?? '';
    // Build complete URL using ApiConfig
    String url = rawUrl.isNotEmpty ? ApiConfig.buildImageUrl(rawUrl) : '';

    // Helper to parse int safely
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return ImageModel(
      url: url,
      altText: json['alt_text']?.toString() ?? json['alt']?.toString(),
      width: parseInt(json['width']),
      height: parseInt(json['height']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'alt_text': altText, 'width': width, 'height': height};
  }
}
