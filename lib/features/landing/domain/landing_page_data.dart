class HeroSlide {
  final String title;
  final String imageUrl;

  const HeroSlide({required this.title, required this.imageUrl});
}

class LandingCategory {
  final String name;

  const LandingCategory({required this.name});
}

class LandingPageData {
  final List<HeroSlide> heroSlides;
  final List<LandingCategory> categories;
  final int bestSellersCount;
  final int newArrivalsCount;

  const LandingPageData({
    required this.heroSlides,
    required this.categories,
    required this.bestSellersCount,
    required this.newArrivalsCount,
  });
}
