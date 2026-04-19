import '../../../services/chatbot_service.dart';
import '../presentation/chatbot_provider.dart';

class ChatbotServiceAdapter implements ChatbotDataSource {
  final ChatbotService _service;

  ChatbotServiceAdapter(this._service);

  @override
  Future<String> send(String message, {List<Map<String, String>>? history}) {
    return _service.getChatResponse(message);
  }
}
