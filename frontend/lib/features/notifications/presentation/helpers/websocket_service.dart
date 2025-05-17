import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/web.dart';
import 'package:reallystick/features/auth/data/storage/token_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _shouldReconnect = true;
  bool _isReconnecting = false;

  final logger = Logger();
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<String> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  StreamSubscription? _webSocketSubscription;

  /// Connect to WebSocket
  void connect() {
    if (_isConnected || _isReconnecting) {
      return;
    }

    _shouldReconnect = true;
    _initializeWebSocket();
  }

  /// Initialize WebSocket Connection
  Future<void> _initializeWebSocket() async {
    if (_isConnected) return;

    final token = await TokenStorage().getAccessToken();
    if (token == null) {
      logger.i("No token found. Retrying in 3 seconds...");
      _handleReconnect();
      return;
    }

    try {
      final baseUrl = dotenv.env['WS_BASE_URL']?.replaceAll('http', 'ws') ?? "";
      final uri = Uri.parse("$baseUrl/api/ws?access_token=$token");

      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;
      _connectionController.add(true);
      logger.i("WebSocket connected");

      // Listen for incoming messages
      _webSocketSubscription = _channel!.stream.listen(
        (message) {
          logger.i("WebSocket message received: $message");
          _messageController.add(message);
        },
        onError: (error) async {
          logger.i("WebSocket stream error: $error");
          if (_webSocketSubscription != null) {
            await _webSocketSubscription!.cancel();
          }
          _webSocketSubscription = null;
          _handleReconnect();
        },
        onDone: () async {
          logger.i("WebSocket connection closed by server.");
          if (_webSocketSubscription != null) {
            await _webSocketSubscription!.cancel();
          }
          _webSocketSubscription = null;
          _handleReconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      logger.i("WebSocket connection error: $e");
      _handleReconnect();
    }
  }

  /// Handle WebSocket Reconnection
  void _handleReconnect() async {
    _isConnected = false;
    _channel = null;
    _connectionController.add(false);

    if (!_shouldReconnect || _isReconnecting) {
      logger.i(
          "returning because _shouldReconnect : $_shouldReconnect and _isReconnecting : $_isReconnecting");
      return;
    }

    _isReconnecting = true;

    while (!_isConnected && _shouldReconnect) {
      await Future.delayed(Duration(seconds: 3));

      if (_isConnected) {
        break;
      }

      logger.i("Reconnecting WebSocket...");
      await _initializeWebSocket();
    }

    _isReconnecting = false;
  }

  /// Disconnect WebSocket
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _isReconnecting = false;

    try {
      if (_webSocketSubscription != null) {
        await _webSocketSubscription!.cancel();
      }
      if (_channel != null) {
        await _channel!.sink.close(1000, "App moved to background");
      }
    } catch (e) {
      logger.i("Error during WebSocket disconnect: $e");
    }

    _webSocketSubscription = null;
    _channel = null;
    _isConnected = false;
    _connectionController.add(false);
  }

  /// Dispose resources (if needed)
  Future<void> dispose() async {
    await disconnect();
    await _messageController.close();
    await _connectionController.close();
  }
}
