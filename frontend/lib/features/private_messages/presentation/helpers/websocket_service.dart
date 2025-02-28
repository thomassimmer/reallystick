import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late WebSocketChannel channel;

  void connect(String accessToken) async {
    final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll('http', 'ws') ?? "";
    final uri = Uri.parse(
      "$baseUrl/api/private-messages/ws?access_token=$accessToken",
    );

    channel = WebSocketChannel.connect(uri);
  }

  void listen(void Function(dynamic) onMessage) {
    channel.stream.listen(
      onMessage,
      onError: _onError,
      onDone: _onDone,
    );
  }

  void _onError(dynamic error) {}

  void _onDone() {}

  void reconnect(String accessToken) {
    connect(accessToken);
  }

  void send(dynamic data) {
    channel.sink.add(
      json.encode(data),
    );
  }

  void disconnect() {
    channel.sink.close();
  }
}
