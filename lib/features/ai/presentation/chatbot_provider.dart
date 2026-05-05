import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/features/ai/data/ai_repository.dart';
import 'package:mitologi_clothing_mobile/features/ai/domain/models/ai_models.dart';

class ChatbotProvider extends ChangeNotifier {
  final AiRepository _repository;

  ChatbotProvider(this._repository);

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String? _error;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  String? get error => _error;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage.user(text);
    _messages.add(userMessage);
    _isTyping = true;
    _error = null;
    notifyListeners();

    try {
      final history = _messages.length > 1 
          ? _messages.sublist(0, _messages.length - 1) 
          : null;

      final response = await _repository.sendMessage(text, history);
      
      if (response != null) {
        _messages.add(ChatMessage.assistant(response.reply));
      } else {
        _error = 'Maaf, saya sedang mengalami kendala teknis.';
      }
    } catch (e) {
      _error = 'Gagal mengirim pesan. Silakan coba lagi.';
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}
