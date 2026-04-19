import 'package:flutter/foundation.dart';

import '../domain/chat_message.dart';

abstract class ChatbotDataSource {
  Future<String> send(String message, {List<Map<String, String>>? history});
}

class ChatbotProvider extends ChangeNotifier {
  final ChatbotDataSource _source;

  ChatbotProvider(this._source);

  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  String? _error;

  List<ChatMessage> get messages => _messages;
  bool get isSending => _isSending;
  String? get error => _error;

  Future<void> send(String message) async {
    _isSending = true;
    _error = null;
    _messages.add(ChatMessage(role: 'user', text: message));
    notifyListeners();

    try {
      final history = _messages
          .take(_messages.length - 1)
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();
      final reply = await _source.send(message, history: history);
      _messages.add(ChatMessage(role: 'assistant', text: reply));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void clear() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}
