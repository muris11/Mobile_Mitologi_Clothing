import '../domain/landing_page_data.dart';

class LandingService {
  LandingService();

  LandingService.forTest();

  Future<LandingPageData> fetchLandingPage() async {
    throw UnimplementedError('fetchLandingPage must be implemented');
  }
}
