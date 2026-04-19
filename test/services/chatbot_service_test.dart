import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/chatbot_service.dart';

import '../helpers/test_binding.dart';
import '../mocks/mock_api_client.dart';

void main() {
  setUpAll(() {
    initializeTestBinding();
  });

  group('ChatbotService Tests', () {
    late MockApiClient mockClient;
    late ApiService apiService;
    late ChatbotService chatbotService;

    setUp(() {
      mockClient = MockApiClient();
      apiService = ApiService(client: mockClient.client);
      chatbotService = ChatbotService(apiService);
    });

    tearDown(() {
      mockClient.clear();
    });

    test('getChatResponse parses nested data reply', () async {
      mockClient.setResponse(
        'POST',
        'https://adminmitologi.based.my.id/api/v1/chatbot',
        {
          'data': {'reply': 'Halo juga'}
        },
      );

      final result = await chatbotService.getChatResponse('Halo');

      expect(result, 'Halo juga');
    });

    test('getRecommendedProducts supports recommended_products key', () async {
      mockClient.setResponse(
        'POST',
        'https://adminmitologi.based.my.id/api/v1/chatbot',
        {
          'data': {
            'recommended_products': [
              {'id': 1, 'name': 'Kemeja A'}
            ]
          }
        },
      );

      final result = await chatbotService.getRecommendedProducts('rekomendasi');

      expect(result, isNotNull);
      expect(result?.length, 1);
      expect(result?.first['name'], 'Kemeja A');
    });
  });
}
