import 'dart:async';
import 'package:app_cliente_novanet/service/notificaciones_Service.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // para debugPrint

class SignalRService {
  HubConnection? _hubConnection;
  final String serverUrl;
  Timer? _reconnectTimer;
  bool _isDisposed = false;

  SignalRService(this.serverUrl);

  Future<void> initialize() async {
    if (_hubConnection != null) return;

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          serverUrl,
          
        )
        .withAutomaticReconnect(
          retryDelays: [0, 2000, 5000, 10000, 30000], // milisegundos
        )
        .build();

    _hubConnection!.onclose(({Exception? error}) {
      debugPrint("SignalR cerrado: $error");
      if (!_isDisposed) _scheduleReconnect();
    });

    _hubConnection!.on("ReceiveMessage", _handleReceiveMessage);

    await _startConnection();
  }

  Future<void> _startConnection() async {
    if (_hubConnection == null) return;

    try {
      if (_hubConnection!.state != HubConnectionState.Connected) {
        await _hubConnection!.start();
        debugPrint("SignalR conectado!");
      }
    } catch (e) {
      debugPrint("Error al conectar SignalR: $e");
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 8), () async {
      if (!_isDisposed) await _startConnection();
    });
  }

  Future<void> _handleReceiveMessage(List<Object?>? arguments) async {
    if (arguments == null || arguments.length < 2) return;

    try {
      final usersRaw = arguments[0];
      final message = arguments[1] as String? ?? '';

      List<String> users = [];
      if (usersRaw is List) {
        users = usersRaw.cast<String>();
      }

      final prefs = await SharedPreferences.getInstance();
      final usuario = prefs.getString('fcUsuarioAcceso') ?? '';

      if (users.isEmpty || users.contains(usuario)) {
        await NotificationService()
            .showNotification("Nueva notificación", message);
      }
    } catch (e) {
      debugPrint("Error procesando notificación: $e");
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    if (_hubConnection != null) {
      try {
        await _hubConnection!.stop();
      } catch (_) {}
      _hubConnection = null;
    }
  }
}