import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:toibook_app/models/chat/chat_event.dart';
import 'package:toibook_app/services/auth_service.dart';

class ChatSocketService {
  static const _wsUrl = 'wss://toibook.up.railway.app/ws-chat';

  StompClient? _client;
  final AuthService _authService = AuthService();

  void Function(ChatEvent)? onEvent;
  void Function()? onConnected;
  void Function()? onDisconnected;

  bool get isConnected => _client?.connected ?? false;

  Future<void> connect() async {
    final token = await _authService.getToken();

    print('Connecting to $_wsUrl');
    print('Token exists: ${token != null && token.isNotEmpty}');

    _client = StompClient(
      config: StompConfig(
        url: 'wss://toibook.up.railway.app/ws-chat',
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        onConnect: _onConnect,
        onDisconnect: (_) {
          print('STOMP disconnected');
          onDisconnected?.call();
        },
        onStompError: (frame) {
          print('STOMP error header: ${frame.headers}');
          print('STOMP error body: ${frame.body}');
        },
        onWebSocketError: (error) {
          print('WebSocket error: $error');
        },
        onWebSocketDone: () {
          print('WebSocket done');
        },
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    print('STOMP connected');
    onConnected?.call();

    _client!.subscribe(
      destination: '/user/queue/chat',
      callback: (frame) {
        print('Incoming socket body: ${frame.body}');

        if (frame.body == null) return;

        try {
          final json = jsonDecode(frame.body!);
          final event = ChatEvent.fromJson(json);
          onEvent?.call(event);
        } catch (e) {
          print('Failed to parse chat event: $e');
        }
      },
    );
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
  }

  void reconnect() {
    disconnect();
    connect();
  }
}
