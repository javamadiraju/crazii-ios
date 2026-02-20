import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'data.dart';

class WebSocketService {
  final IO.Socket socket;
  final StreamController<MarketData> _controller =
      StreamController<MarketData>.broadcast();

  final String pair;

  bool _isDisposed = false;
  bool _shouldReconnect = true;

  WebSocketService(this.pair)
      : socket = IO.io("https://cgmembers.com/", {
          "transports": ["websocket"],
          "autoConnect": false,
        }) {
    print("--------------------------------------------------");
    print("🔌 WS SERVICE CREATED for → $pair");
    print("--------------------------------------------------");

    _attachEvents();
    socket.connect();
  }

  void _attachEvents() {
    socket.on("connect", (_) {
      if (_isDisposed) return;

      print("🟢 [WS:$pair] CONNECTED.");
      print("📡 [WS:$pair] Subscribing to broadcast…");

      socket.emit("subscribe", jsonEncode({"channel": "broadcast"}));

      final eventName = "chart.$pair.5";

      print("🧹 [WS:$pair] Removing old listeners before adding new.");
      socket.off(eventName);

      print("👂 [WS:$pair] Adding listener for → $eventName");
      socket.on(eventName, _handleMessage);
    });

    socket.on("disconnect", (reason) {
      print("🔴 [WS:$pair] DISCONNECTED → $reason");

      if (_isDisposed || !_shouldReconnect) return;

      print("🔁 [WS:$pair] Trying reconnect after 5 seconds...");
      Future.delayed(Duration(seconds: 5), () {
        if (_isDisposed || !_shouldReconnect) return;
        socket.connect();
      });
    });

    socket.on("connect_error", (e) {
      print("❌ [WS:$pair] CONNECT ERROR → $e");
    });

    socket.on("error", (e) {
      print("❌ [WS:$pair] SOCKET ERROR → $e");
    });
  }

  void _handleMessage(dynamic raw) {
    if (_isDisposed) return;

    print("📥 [WS:$pair] RAW WS DATA: $raw");

    try {
      final parsed = MarketData.fromList(raw); 

      _controller.add(parsed);
    } catch (e) {
      print("❌ [WS:$pair] PARSE ERROR → $e");
    }
  }

  Stream<MarketData> get stream {
    print("📬 [WS:$pair] Stream accessed.");
    return _controller.stream;
  }

  void dispose() {
    print("🧹 [WS:$pair] CLEANING UP…");

    _isDisposed = true;
    _shouldReconnect = false;

    try {
      final eventName = "chart.$pair.5";

      socket.off(eventName);
      socket.off("connect");
      socket.off("disconnect");
      socket.off("error");
      socket.dispose();

      print("🔌 [WS:$pair] Socket disposed.");
    } catch (e) {
      print("⚠️ [WS:$pair] Error disposing socket → $e");
    }

    try {
      _controller.close();
      print("📭 [WS:$pair] StreamController closed.");
    } catch (e) {
      print("⚠️ [WS:$pair] Error closing controller → $e");
    }

    print("✅ [WS:$pair] FULLY DISPOSED.");
  }
}
