import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  String? _token;
  bool _isConnected = false;
  bool _shouldReconnect = false;
  bool _isReconnecting = false; // Prevent race conditions in reconnection

  final StreamController<String> _messageController =
      StreamController.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<String> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  StreamSubscription? _webSocketSubscription;

  /// Connect to WebSocket
  void connect(String token) {
    if (_isConnected || _channel != null) {
      return; // Prevent opening multiple connections
    }

    _token = token;
    _shouldReconnect = true;
    _initializeWebSocket();
  }

  /// Initialize WebSocket Connection
  Future<void> _initializeWebSocket() async {
    if (_channel != null) {
      return; // Ensure only one socket is open
    }

    try {
      final baseUrl = dotenv.env['WS_BASE_URL']?.replaceAll('http', 'ws') ?? "";
      final uri = Uri.parse("$baseUrl/api/ws?access_token=$_token");

      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;

      _isConnected = true;
      _connectionController.add(true); // Notify about successful connection

      // Listen for incoming messages
      _webSocketSubscription = _channel!.stream.listen(
        (message) {
          _messageController.add(message);
        },
        onError: (error) => _handleReconnect(),
        onDone: () => _handleReconnect(),
        cancelOnError: true,
      );
    } catch (e) {
      print("WebSocket connection error: $e");
      _handleReconnect();
    }
  }

  /// Handle WebSocket Reconnection
  void _handleReconnect() async {
    _channel = null;

    if (!_shouldReconnect || _isReconnecting) {
      return; // Prevent multiple reconnections
    }

    _isConnected = false;
    _connectionController.add(false);
    _isReconnecting = true;

    while (!_isConnected && _shouldReconnect) {
      await Future.delayed(Duration(seconds: 3));

      if (_isConnected || _channel != null) {
        _isReconnecting = false;
        return;
      }

      await _initializeWebSocket();

      _isReconnecting = false;
    }
  }

  /// Disconnect WebSocket
  Future<void> disconnect() async {
    if (kIsWeb) return; // No explicit disconnect needed on web

    _shouldReconnect = false;
    _isReconnecting = false;

    if (_channel != null) {
      try {
        await _channel!.sink.close(1000, "App moved to background");
        await _webSocketSubscription?.cancel();
      } catch (e) {
        print("Error closing WebSocket: $e");
      }

      _webSocketSubscription = null;
      _channel = null;
    }

    _isConnected = false;
    _connectionController.add(false);
  }
}
