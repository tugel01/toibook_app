import 'package:flutter/material.dart';
import 'package:toibook_app/models/chat/chat_event.dart';
import 'package:toibook_app/models/chat/chat_message.dart';
import 'package:toibook_app/models/chat/conversation_preview.dart';
import 'package:toibook_app/services/chat_service.dart';
import 'package:toibook_app/services/chat_socket_service.dart';

class ChatProvider with ChangeNotifier {
  final _chatService = ChatService();
  final _socketService = ChatSocketService();

  // Conversations list
  List<ConversationPreview> _conversations = [];
  bool _isLoadingConversations = false;
  String? _conversationsError;

  List<ConversationPreview> get conversations => _conversations;
  bool get isLoadingConversations => _isLoadingConversations;
  String? get conversationsError => _conversationsError;

  // Messages per conversation
  final Map<int, List<ChatMessage>> _messages = {};
  final Map<int, bool> _isLoadingMessages = {};
  final Map<int, String?> _messagesError = {};

  List<ChatMessage> messagesFor(int conversationId) =>
      _messages[conversationId] ?? [];
  bool isLoadingMessagesFor(int conversationId) =>
      _isLoadingMessages[conversationId] ?? false;
  String? messagesErrorFor(int conversationId) =>
      _messagesError[conversationId];

  // Socket state
  bool _isSocketConnected = false;
  bool get isSocketConnected => _isSocketConnected;

  // needed to distinguish sent vs received
  int? currentUserId;

  void init(int userId) {
    currentUserId = userId;
    _socketService.onEvent = _handleSocketEvent;
    _socketService.onConnected = () {
      _isSocketConnected = true;
      notifyListeners();
    };
    _socketService.onDisconnected = () {
      _isSocketConnected = false;
      notifyListeners();
    };
    _socketService.connect();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  // Load conversations
  Future<void> loadConversations() async {
    _isLoadingConversations = true;
    _conversationsError = null;
    notifyListeners();

    try {
      _conversations = await _chatService.getConversations();
    } catch (e) {
      _conversationsError = e.toString();
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  // Load messages for a conversation
  Future<void> loadMessages(int conversationId) async {
    _isLoadingMessages[conversationId] = true;
    _messagesError[conversationId] = null;
    notifyListeners();

    try {
      final messages = await _chatService.getMessages(conversationId);
      _messages[conversationId] = messages;

      // Mark incoming unread messages as delivered
      for (final msg in messages) {
        if (msg.senderId != currentUserId && msg.status == MessageStatus.sent) {
          _chatService.markDelivered(msg.id);
        }
      }
    } catch (e) {
      _messagesError[conversationId] = e.toString();
    } finally {
      _isLoadingMessages[conversationId] = false;
      notifyListeners();
    }
  }

  // Mark conversation as read
  Future<void> markRead(int conversationId) async {
    try {
      await _chatService.markRead(conversationId);
      // Update unread count locally
      final index = _conversations.indexWhere(
        (c) => c.conversationId == conversationId,
      );
      if (index != -1) {
        _conversations[index] = ConversationPreview(
          conversationId: _conversations[index].conversationId,
          otherParticipantId: _conversations[index].otherParticipantId,
          otherParticipantName: _conversations[index].otherParticipantName,
          lastMessageText: _conversations[index].lastMessageText,
          lastMessageCreatedAt: _conversations[index].lastMessageCreatedAt,
          unreadCount: 0,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Failed to mark read: $e');
    }
  }

  // Send message
  Future<void> sendMessage(int conversationId, String text) async {
    try {
      final message = await _chatService.sendMessage(conversationId, text);
      _messages[conversationId] = [
        ...(_messages[conversationId] ?? []),
        message,
      ];
      _updateConversationPreview(conversationId, message.text);
      notifyListeners();
    } catch (e) {
      print('Failed to send message: $e');
      rethrow;
    }
  }

  // Get or create conversation
  Future<int> getOrCreateConversation(int vendorId) async {
    try {
      final conversation = await _chatService.getOrCreateConversation(vendorId);
      // Refresh conversations list
      await loadConversations();
      return conversation.id;
    } catch (e) {
      throw Exception('Failed to get/create conversation: $e');
    }
  }

  // Handle incoming socket events
  void _handleSocketEvent(ChatEvent event) {
    switch (event.type) {
      case ChatEventType.messageSent:
        _handleMessageSent(event);
        break;
      case ChatEventType.messageDelivered:
        _handleMessageDelivered(event);
        break;
      case ChatEventType.messageRead:
        _handleMessageRead(event);
        break;
    }
  }

  void _handleMessageSent(ChatEvent event) {
    if (event.senderId == currentUserId) return;

    final messages = _messages[event.conversationId];
    if (messages != null) {
      _messages[event.conversationId] = [
        ...messages,
        ChatMessage(
          id: event.messageId,
          conversationId: event.conversationId,
          senderId: event.senderId,
          text: event.text ?? '',
          status: MessageStatus.sent,
          createdAt: event.createdAt,
        ),
      ];
    }

    _updateConversationPreview(event.conversationId, event.text ?? '');

    // Mark as delivered
    _chatService.markDelivered(event.messageId);
    notifyListeners();
  }

  void _handleMessageDelivered(ChatEvent event) {
    _updateMessageStatus(
      event.conversationId,
      event.messageId,
      MessageStatus.delivered,
    );
  }

  void _handleMessageRead(ChatEvent event) {
    _updateMessageStatus(
      event.conversationId,
      event.messageId,
      MessageStatus.read,
    );
  }

  void _updateMessageStatus(
    int conversationId,
    int messageId,
    MessageStatus status,
  ) {
    final messages = _messages[conversationId];
    if (messages == null) return;

    _messages[conversationId] =
        messages.map((m) {
          if (m.id == messageId) return m.copyWith(status: status);
          return m;
        }).toList();

    notifyListeners();
  }

  void _updateConversationPreview(int conversationId, String lastMessage) {
    final index = _conversations.indexWhere(
      (c) => c.conversationId == conversationId,
    );
    if (index == -1) return;

    final conv = _conversations[index];
    _conversations[index] = ConversationPreview(
      conversationId: conv.conversationId,
      otherParticipantId: conv.otherParticipantId,
      otherParticipantName: conv.otherParticipantName,
      lastMessageText: lastMessage,
      lastMessageCreatedAt: DateTime.now().toIso8601String(),
      unreadCount: conv.unreadCount,
    );
    notifyListeners();
  }

  void reconnectSocket() {
    _socketService.reconnect();
  }
}
