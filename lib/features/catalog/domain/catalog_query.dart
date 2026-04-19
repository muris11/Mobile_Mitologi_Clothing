class CatalogQuery {
  final String? search;
  final String? category;
  final String? sortKey;
  final bool? reverse;
  final int page;
  final int limit;
  final double? minPrice;
  final double? maxPrice;

  const CatalogQuery({
    this.search,
    this.category,
    this.sortKey,
    this.reverse,
    this.page = 1,
    this.limit = 20,
    this.minPrice,
    this.maxPrice,
  });

  Map<String, String> toQueryParameters() {
    return {
      if (search != null && search!.trim().isNotEmpty) 'q': search!.trim(),
      if (category != null && category!.trim().isNotEmpty)
        'category': category!.trim(),
      if (sortKey != null && sortKey!.trim().isNotEmpty) 'sortKey': sortKey!.trim(),
      if (reverse != null) 'reverse': reverse.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
      if (minPrice != null) 'minPrice': minPrice.toString(),
      if (maxPrice != null) 'maxPrice': maxPrice.toString(),
    };
  }
}
