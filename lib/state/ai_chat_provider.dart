import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

class ChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime createdAt;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.isLoading = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      role: json['role'] ?? 'assistant',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  factory ChatMessage.loading() => ChatMessage(
        id: 'loading',
        role: 'assistant',
        content: '',
        createdAt: DateTime.now(),
        isLoading: true,
      );
}

class AiChatProvider extends ChangeNotifier {
  final _api = ApiClient.instance;

  List<ChatMessage> _messages = [];
  String? _conversationId;
  bool _isSending = false;
  String? _error;

  List<ChatMessage> get messages => _messages;
  String? get conversationId => _conversationId;
  bool get isSending => _isSending;
  String? get error => _error;

  void startNewChat() {
    _messages = [];
    _conversationId = null;
    _error = null;
    notifyListeners();
  }

  Future<void> loadConversation(String id) async {
    try {
      final data = await _api.getConversation(id);
      _conversationId = id;
      _messages = (data['messages'] as List?)
              ?.map((m) => ChatMessage.fromJson(m))
              .toList() ??
          [];
      notifyListeners();
    } catch (e) {
      _error = 'Could not load this conversation. Check your connection.';
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text, {String? context}) async {
    if (_isSending || text.trim().isEmpty) return;

    _error = null;
    _isSending = true;

    final userMsg = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );
    _messages = [..._messages, userMsg, ChatMessage.loading()];
    notifyListeners();

    try {
      final data = await _api.sendAiMessage(
        message: text,
        conversationId: _conversationId,
        context: context,
      );

      _conversationId = data['conversationId'];
      final reply = ChatMessage.fromJson(data['message']);

      _messages = [
        ..._messages.where((m) => !m.isLoading),
        reply,
      ];
    } on ApiException catch (e) {
      // The backend was reachable but returned an error. Keep the real call as
      // primary and surface an honest, non-technical message instead of the raw
      // server error. There is no offline/mock AI — an answer needs the backend.
      _messages = _messages.where((m) => !m.isLoading).toList();
      _error = e.statusCode == 401
          ? 'AI chat needs you to be signed in. Please sign in and try again.'
          : 'AI chat is temporarily unavailable. Please try again in a moment.';
    } catch (e) {
      // Network/connectivity failure (no route, DNS, timeout, TLS, etc.).
      _messages = _messages.where((m) => !m.isLoading).toList();
      _error =
          'AI chat needs a connection. Check your internet and try again.';
    }

    _isSending = false;
    notifyListeners();
  }
}
