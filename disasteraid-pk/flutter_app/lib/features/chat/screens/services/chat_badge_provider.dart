import 'package:flutter/material.dart';
import 'package:disasteraid_pk/core/api/api_client.dart';

class ChatBadgeProvider extends ChangeNotifier {
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;
  final _api = ApiClient();

  Future<void> refreshUnread() async {
    try {
      final res = await _api.dio.get('/chat');
      // Backend now returns {success: true, data: [...]}
      final chats = List<Map<String, dynamic>>.from(res.data);
      _unreadCount = chats.fold(0, (sum, chat) => sum + (chat['unread_count'] as int? ?? 0));
      notifyListeners();
    } catch (e) {
      debugPrint('Badge refresh error: $e');
      _unreadCount = 0;
      notifyListeners();
    }
  }

  void clear() {
    _unreadCount = 0;
    notifyListeners();
  }

  void decrement([int count = 1]) {
    if (_unreadCount > 0) {
      _unreadCount = (_unreadCount - count).clamp(0, _unreadCount);
      notifyListeners();
    }
  }
}