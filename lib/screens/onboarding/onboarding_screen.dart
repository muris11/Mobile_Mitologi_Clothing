import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/secure_storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Belanja Mudah & Cepat',
      'desc':
          'Temukan koleksi eksklusif dengan navigasi intuitif dan checkout kilat.',
      'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800'
    },
    {
      'title': 'Fashion Berkualitas',
      'desc': 'Jelajahi pilihan pakaian premium dengan bahan terbaik.',
      'image':
          'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800'
    },
    {
      'title': 'Pengiriman Cepat',
      'desc': 'Pesanan Anda dikirim dengan aman dan cepat.',
      'image': 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800'
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await SecureStorageService.setOnboardingCompleted(true);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('The Tactile Atelier',
                    style: GoogleFonts.notoSerif(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primary)),
                TextButton(
                  onPressed: _finish,
                  style: TextButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerLow,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8)),
                  child: Text('Lewati',
                      style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary)),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 10))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: CachedNetworkImage(
                            imageUrl: _pages[index]['image'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.surfaceContainerLow,
                              child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surfaceContainerHigh,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(_pages[index]['title'],
                        style: GoogleFonts.notoSerif(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primary),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Text(_pages[index]['desc'],
                        style: GoogleFonts.manrope(
                            fontSize: 14, color: AppColors.onSurfaceVariant),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(48))),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _currentPage == index ? 32 : 8,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? AppColors.primary
                                    : AppColors.outlineVariant
                                        .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            )),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut);
                        } else {
                          _finish();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              _currentPage < _pages.length - 1
                                  ? 'Lanjut'
                                  : 'Mulai Belanja',
                              style: GoogleFonts.manrope(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
