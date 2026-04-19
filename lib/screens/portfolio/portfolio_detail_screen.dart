import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../services/product_service.dart';

class PortfolioDetailScreen extends StatefulWidget {
  final String slug;
  const PortfolioDetailScreen({super.key, required this.slug});

  @override
  State<PortfolioDetailScreen> createState() => _PortfolioDetailScreenState();
}

class _PortfolioDetailScreenState extends State<PortfolioDetailScreen> {
  Map<String, dynamic>? _portfolio;
  List<Map<String, dynamic>> _relatedPortfolios = [];
  bool _isLoading = true;
  String? _error;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    try {
      final productService = context.read<ProductService>();
      final responses = await Future.wait([
        productService.getPortfolioDetail(widget.slug),
        productService.getPortfolios(),
      ]);

      final detailResponse = responses[0] as Map<String, dynamic>;
      final portfoliosResponse =
          (responses[1] as List).cast<Map<String, dynamic>>();

      final portfolio = _extractPortfolio(detailResponse);
      final relatedFromDetail = _extractRelatedPortfolios(detailResponse);
      final relatedFallback = portfoliosResponse
          .where((item) => _getSlug(item) != widget.slug)
          .toList();

      if (!mounted) return;
      setState(() {
        _portfolio = portfolio;
        _relatedPortfolios =
            relatedFromDetail.isNotEmpty ? relatedFromDetail : relatedFallback;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat portfolio: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? _extractPortfolio(Map<String, dynamic> response) {
    final dynamic dataNode = response['data'];
    final Map<String, dynamic> payload =
        dataNode is Map<String, dynamic> ? dataNode : response;

    final dynamic portfolioNode =
        payload['portfolio'] ?? response['portfolio'] ?? payload;
    if (portfolioNode is Map<String, dynamic>) {
      return portfolioNode;
    }
    return null;
  }

  List<Map<String, dynamic>> _extractRelatedPortfolios(
      Map<String, dynamic> response) {
    final dynamic dataNode = response['data'];
    final Map<String, dynamic> payload =
        dataNode is Map<String, dynamic> ? dataNode : response;

    final dynamic relatedNode = payload['relatedPortfolios'] ??
        payload['related_portfolios'] ??
        payload['relatedPortfolio'] ??
        payload['related'] ??
        response['relatedPortfolios'] ??
        response['related_portfolios'];

    if (relatedNode is List) {
      return relatedNode
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return [];
  }

  String _cleanString(dynamic value) => value?.toString().trim() ?? '';

  String _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      final text = _cleanString(value);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _getSlug(Map<String, dynamic> item) {
    return _cleanString(item['slug'] ?? item['handle'] ?? item['id']);
  }

  List<String> _portfolioImageFields() {
    final fields = <String>[];
    final portfolio = _portfolio;
    if (portfolio == null) return fields;

    for (final key in const [
      'gallery',
      'images',
      'image',
      'imageUrl',
      'image_url',
      'thumbnail',
      'cover',
      'banner',
      'heroImage',
      'hero_image',
      'mainImage',
      'main_image',
    ]) {
      final value = portfolio[key];
      if (value == null) continue;
      if (value is List) {
        for (final item in value) {
          final url = _getImageUrl(item);
          if (url != null && !fields.contains(url)) {
            fields.add(url);
          }
        }
      } else {
        final url = _getImageUrl(value);
        if (url != null && !fields.contains(url)) {
          fields.add(url);
        }
      }
    }

    return fields;
  }

  String? _getImageUrl(dynamic imageData) {
    if (imageData == null) return null;

    String? imageUrl;
    if (imageData is String) {
      imageUrl = imageData;
    } else if (imageData is Map) {
      imageUrl = imageData['url'] ??
          imageData['imageUrl'] ??
          imageData['image_url'] ??
          imageData['image'];
    }

    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        !imageUrl.startsWith('http')) {
      imageUrl = 'https://adminmitologi.based.my.id/storage/$imageUrl';
    }
    return imageUrl;
  }

  List<String> _getGalleryImages() {
    return _portfolioImageFields();
  }

  Widget _buildRelatedPortfoliosSection() {
    if (_relatedPortfolios.isEmpty) return const SizedBox.shrink();

    final relatedItems = _relatedPortfolios
        .where((item) => _getSlug(item) != widget.slug)
        .toList();

    if (relatedItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portfolio Lainnya',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: relatedItems.length,
            itemBuilder: (context, index) {
              final item = relatedItems[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _RelatedPortfolioCard(item: item),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _portfolio == null
                  ? _buildEmpty()
                  : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 16,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPortfolio,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined,
              size: 64, color: AppColors.outline),
          const SizedBox(height: 16),
          Text(
            'Portfolio tidak ditemukan',
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final portfolio = _portfolio ?? <String, dynamic>{};
    final title = _firstNonEmptyString([
      portfolio['title'],
      portfolio['name'],
      portfolio['label'],
      portfolio['headline'],
    ]);
    final resolvedTitle = title.isEmpty ? 'Portfolio' : title;
    final category = _firstNonEmptyString([
      portfolio['category'],
      portfolio['category_name'],
      portfolio['type'],
      portfolio['collection'],
    ]);
    final description = _firstNonEmptyString([
      portfolio['description'],
      portfolio['desc'],
      portfolio['content'],
      portfolio['details'],
      portfolio['summary'],
    ]);
    final clientName = _firstNonEmptyString([
      portfolio['clientName'],
      portfolio['client_name'],
      portfolio['client'],
      portfolio['customer'],
    ]);
    final projectDate = _firstNonEmptyString([
      portfolio['projectDate'],
      portfolio['project_date'],
      portfolio['date'],
      portfolio['year'],
      portfolio['created_at'],
    ]);
    final galleryImages = _getGalleryImages();

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          pinned: true,
          expandedHeight: 400,
          backgroundColor: AppColors.background,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _buildImageGallery(galleryImages),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                if (category.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.full),
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                if (category.isNotEmpty) const SizedBox(height: 16),

                // Title
                Text(
                  resolvedTitle,
                  style: GoogleFonts.notoSerif(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),

                // Meta info (client & date)
                if (clientName.isNotEmpty || projectDate.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                    ),
                    child: Row(
                      children: [
                        if (clientName.isNotEmpty) ...[
                          Icon(Icons.business,
                              size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Klien',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  clientName,
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (projectDate.isNotEmpty) ...[
                          const SizedBox(width: 24),
                          Icon(Icons.calendar_today,
                              size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                projectDate,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                if (clientName.isNotEmpty || projectDate.isNotEmpty)
                  const SizedBox(height: 24),

                // Description
                if (description.isNotEmpty) ...[
                  Text(
                    'Deskripsi Proyek',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Gallery thumbnail grid
                if (galleryImages.length > 1) ...[
                  Text(
                    'Galeri',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGalleryGrid(galleryImages),
                  const SizedBox(height: 32),
                ],

                _buildRelatedPortfoliosSection(),
                if (_relatedPortfolios.isNotEmpty) const SizedBox(height: 32),

                // Contact CTA
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tertarik dengan project serupa?',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hubungi kami untuk diskusi lebih lanjut tentang kebutuhan produksi Anda.',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => context.push('/chatbot'),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Chat dengan Kami'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(List<String> images) {
    if (images.isEmpty) {
      return Container(
        color: AppColors.surfaceContainerHigh,
        child: Icon(Icons.image, size: 64, color: AppColors.outline),
      );
    }

    return PageView.builder(
      itemCount: images.length,
      onPageChanged: (index) => setState(() => _currentImageIndex = index),
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: images[index],
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: AppColors.surfaceContainerLow,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (_, __, ___) => Container(
            color: AppColors.surfaceContainerHigh,
            child: Icon(Icons.image_not_supported,
                size: 64, color: AppColors.outline),
          ),
        );
      },
    );
  }

  Widget _buildGalleryGrid(List<String> images) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentImageIndex;
          return GestureDetector(
            onTap: () {
              setState(() => _currentImageIndex = index);
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 3)
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.surfaceContainerLow,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surfaceContainerHigh,
                    child: Icon(Icons.image_not_supported,
                        color: AppColors.outline),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RelatedPortfolioCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _RelatedPortfolioCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final slug = item['slug']?.toString() ?? '';
    final title =
        item['title']?.toString() ?? item['name']?.toString() ?? 'Portfolio';
    final category = item['category']?.toString() ?? '';
    final imageUrl = _resolveImageUrl(item);

    return SizedBox(
      width: 180,
      child: GestureDetector(
        onTap: slug.isNotEmpty ? () => context.push('/portfolio/$slug') : null,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
            boxShadow: [AppShadows.card],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: imageUrl == null
                      ? Container(
                          color: AppColors.surfaceContainerHigh,
                          child: Icon(Icons.image, color: AppColors.outline),
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.surfaceContainerLow,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surfaceContainerHigh,
                            child: Icon(Icons.image_not_supported,
                                color: AppColors.outline),
                          ),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (category.isNotEmpty)
                          Text(
                            category,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          'Lihat detail',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _resolveImageUrl(Map<String, dynamic> item) {
    final dynamic imageData = item['image'] ??
        item['imageUrl'] ??
        item['image_url'] ??
        item['thumbnail'] ??
        item['cover'];

    if (imageData == null) return null;

    String? imageUrl;
    if (imageData is String) {
      imageUrl = imageData;
    } else if (imageData is Map) {
      imageUrl = imageData['url'] ??
          imageData['imageUrl'] ??
          imageData['image_url'] ??
          imageData['image'];
    }

    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        !imageUrl.startsWith('http')) {
      imageUrl = 'https://adminmitologi.based.my.id/storage/$imageUrl';
    }
    return imageUrl;
  }
}
