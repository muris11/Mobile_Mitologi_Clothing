import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/features/chatbot/presentation/chatbot_provider.dart';

class FakeChatbotSource implements ChatbotDataSource {
  String reply = 'Halo';
  Exception? error;

  @override
  Future<String> send(String message, {List<Map<String, String>>? history}) async {
    if (error != null) throw error!;
    return reply;
  }
}

void main() {
  group('ChatbotProvider', () {
    test('send message appends user and assistant messages', () async {
      final provider = ChatbotProvider(FakeChatbotSource());

      await provider.send('Hai');

      expect(provider.messages.length, 2);
      expect(provider.messages.first.role, 'user');
      expect(provider.messages.last.role, 'assistant');
      expect(provider.error, isNull);
    });

    test('send failure sets error state', () async {
      final source = FakeChatbotSource()..error = Exception('boom');
      final provider = ChatbotProvider(source);

      await provider.send('Hai');

      expect(provider.error, contains('boom'));
    });
  });
}
