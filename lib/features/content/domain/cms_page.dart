class CmsPage {
  final String handle;
  final String title;
  final String body;
  final String? excerpt;
  final String? imageUrl;

  const CmsPage({
    required this.handle,
    required this.title,
    required this.body,
    this.excerpt,
    this.imageUrl,
  });
}
