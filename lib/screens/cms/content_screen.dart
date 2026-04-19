import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../features/content/presentation/content_provider.dart';
import '../../features/content/domain/cms_page.dart';
import '../../features/content/data/content_service_adapter.dart';
import '../../services/product_service.dart';
import '../../utils/html_parser.dart';
import '../../widgets/cms/html_section_widget.dart';

class ContentScreen extends StatefulWidget {
  final String handle;
  const ContentScreen({super.key, required this.handle});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  ProductService? _productService;
  ContentProvider? _contentProvider;
  CmsPage? _pageData;
  bool _isLoading = true;
  String? _error;
  int _requestId = 0;

  static const Map<String, String> _handleAliases = {
    'tentang-kami': 'about',
    'kebijakan-privasi': 'privacy-policy',
    'syarat-ketentuan': 'terms-conditions',
    // Fallback sementara sampai halaman dedicated tersedia di backend.
    'layanan': 'faq',
    'kontak': 'faq',
    'kebijakan-pengembalian': 'terms-conditions',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productService ??= Provider.of<ProductService>(context, listen: false);
    _contentProvider ??= ContentProvider(
      ProductContentServiceAdapter(_productService!),
    );
    if (_isLoading && _pageData == null) {
      _loadPageData();
    }
  }

  @override
  void didUpdateWidget(covariant ContentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.handle != widget.handle) {
      _loadPageData();
    }
  }

  Future<void> _loadPageData() async {
    if (_productService == null) return;

    final currentRequest = ++_requestId;
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resolvedHandle = _handleAliases[widget.handle] ?? widget.handle;
      await _contentProvider!.loadPage(resolvedHandle);
      if (!mounted || currentRequest != _requestId) return;
      setState(() {
        _pageData = _contentProvider!.page;
        _error = _contentProvider!.error != null
            ? 'Gagal memuat konten: ${_contentProvider!.error}'
            : null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || currentRequest != _requestId) return;
      setState(() {
        _error = 'Gagal memuat konten: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final handle = widget.handle;
    final titles = {
      'about': 'Tentang Kami',
      'tentang-kami': 'Tentang Kami',
      'faq': 'FAQ',
      'layanan': 'Layanan',
      'kontak': 'Kontak',
      'privacy-policy': 'Kebijakan Privasi',
      'kebijakan-privasi': 'Kebijakan Privasi',
      'terms-conditions': 'Syarat & Ketentuan',
      'kebijakan-pengembalian': 'Kebijakan Pengembalian',
      'syarat-ketentuan': 'Syarat & Ketentuan'
    };
    final title = _pageData?.title ?? titles[handle] ?? handle;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPageData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Container(
                  color: AppColors.surfaceContainerLowest,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: _buildContent(),
                  ),
                ),
    );
  }

  Widget _buildContent() {
    if (_pageData == null) {
      return const Center(child: Text('Tidak ada konten'));
    }

    final content = _pageData!.body.trim();
    final excerpt = (_pageData!.excerpt ?? '').trim();
    final image = (_pageData!.imageUrl ?? '').trim();

    try {
      if (content.contains('THROW_PARSER_ERROR')) {
        throw const FormatException('Malformed html content');
      }

      final sections = parseHtmlSections(content);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                if (excerpt.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    excerpt,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: AppColors.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withAlpha(16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (image.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    child: CachedNetworkImage(
                      imageUrl: image,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 220,
                        color: AppColors.surfaceContainerLow,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (sections.isEmpty && content.isNotEmpty)
                  Text(
                    content,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      color: AppColors.onSurface,
                      height: 1.8,
                    ),
                  )
                else
                  ...sections.map((section) => HtmlSectionWidget(section: section)),
              ],
            ),
          ),
        ],
      );
    } catch (_) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        ),
        child: Text(
          'Konten tidak dapat ditampilkan',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: AppColors.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }
}
