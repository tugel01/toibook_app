import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toibook_app/models/chat/chat_message.dart';
import 'package:toibook_app/models/chat/conversation_preview.dart';
import 'package:toibook_app/models/chat/conversation_response.dart';
import 'package:toibook_app/services/auth_service.dart';

class ChatService {
  final _baseUrl = 'https://toibook.up.railway.app/api';
  final _authService = AuthService();

  Future<Map<String, String>> get _headers async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  Future<ConversationResponse> getOrCreateConversation(int vendorId) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/chat/conversations/vendors/$vendorId'),
        headers: await _headers,
      );
      print('getOrCreateConversation url: $_baseUrl/chat/conversations/vendors/$vendorId');
      print('getOrCreateConversation status: ${res.statusCode}');
      print('getOrCreateConversation body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        return ConversationResponse.fromJson(jsonDecode(res.body));
      }
      throw Exception('Failed to get/create conversation: ${res.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<ConversationPreview>> getConversations() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/chat/conversations'),
        headers: await _headers,
      );

      if (res.statusCode == 200) {
        final List<dynamic> body = jsonDecode(res.body);
        return body.map((e) => ConversationPreview.fromJson(e)).toList();
      }
      if (res.statusCode == 404) return [];
      throw Exception('Failed to load conversations: ${res.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<ChatMessage>> getMessages(int conversationId) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/chat/conversations/$conversationId/messages'),
        headers: await _headers,
      );

      if (res.statusCode == 200) {
        final List<dynamic> body = jsonDecode(res.body);
        return body.map((e) => ChatMessage.fromJson(e)).toList();
      }
      if (res.statusCode == 404) return [];
      throw Exception('Failed to load messages: ${res.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ChatMessage> sendMessage(int conversationId, String text) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/chat/conversations/$conversationId/messages'),
        headers: await _headers,
        body: jsonEncode({'text': text}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return ChatMessage.fromJson(jsonDecode(res.body));
      }
      throw Exception('Failed to send message: ${res.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> markDelivered(int messageId) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/chat/messages/$messageId/delivered'),
        headers: await _headers,
      );

      if (res.statusCode != 200) {
        throw Exception('Failed to mark delivered: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> markRead(int conversationId) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/chat/conversations/$conversationId/read'),
        headers: await _headers,
      );

      if (res.statusCode != 200) {
        throw Exception('Failed to mark read: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
