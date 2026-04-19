import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/features/landing/data/landing_service.dart';
import 'package:mitologi_clothing_mobile/features/landing/domain/landing_page_data.dart';
import 'package:mitologi_clothing_mobile/features/landing/presentation/landing_provider.dart';

class FakeLandingService extends LandingService {
  FakeLandingService() : super.forTest();

  LandingPageData? nextData;
  Exception? nextError;

  @override
  Future<LandingPageData> fetchLandingPage() async {
    if (nextError != null) throw nextError!;
    return nextData!;
  }
}

void main() {
  group('LandingProvider', () {
    test('loads landing data successfully', () async {
      final service = FakeLandingService()
        ..nextData = const LandingPageData(
          heroSlides: [HeroSlide(title: 'Hero', imageUrl: 'img')],
          categories: [LandingCategory(name: 'Outer')],
          bestSellersCount: 2,
          newArrivalsCount: 1,
        );
      final provider = LandingProvider(service);

      await provider.load();

      expect(provider.heroSlides.length, 1);
      expect(provider.categories.length, 1);
      expect(provider.bestSellersCount, 2);
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
    });

    test('exposes error state when load fails', () async {
      final service = FakeLandingService()..nextError = Exception('boom');
      final provider = LandingProvider(service);

      await provider.load();

      expect(provider.error, contains('boom'));
      expect(provider.isLoading, isFalse);
    });

    test('handles missing optional sections', () async {
      final service = FakeLandingService()
        ..nextData = const LandingPageData(
          heroSlides: [],
          categories: [],
          bestSellersCount: 0,
          newArrivalsCount: 0,
        );
      final provider = LandingProvider(service);

      await provider.load();

      expect(provider.heroSlides, isEmpty);
      expect(provider.categories, isEmpty);
      expect(provider.error, isNull);
    });
  });
}
