import 'dart:async';
import 'package:app_cliente_novanet/models/MessageViewModel.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatSignalRService {
  late HubConnection _hubConnection;
  final String _serverUrl;
  bool _isConnected = false;
  String? _assignedSupportAgent;
  final List<Message> _messages = [];
  Function(String)? onUserTyping;
  Function(String)? onAssignedSupportAgent;
  Function(String)? onUserStoppedTyping;
  Function(Message)? onMessageReceived;

  ChatSignalRService(this._serverUrl);

  /// Inicializa la conexión con SignalR y configura los eventos
  Future<void> init() async {
    try {
      _hubConnection = HubConnectionBuilder()
          .withUrl(_serverUrl)
          .withAutomaticReconnect()
          .build();

      _hubConnection.onclose(({Exception? error}) {
        _isConnected = false;
        Future.delayed(const Duration(seconds: 5), _reconnect);
      });

      // 📩 Escuchar mensajes entrantes
      _hubConnection.on("ReceiveMessage", (arguments) {
        if (arguments is List && arguments.isNotEmpty) {
          final data = arguments[0];
          if (data is Map<String, dynamic>) {
            final msg = Message.fromJson(data);
            _messages.add(msg);
            print("📩 Nuevo mensaje de ${msg.senderId}: ${msg.text} | Tipo: ${msg.messageType}");
            if (onMessageReceived != null) onMessageReceived!(msg);
          } else {
            print("⚠️ Error: El argumento no es un Map: $data");
          }
        } else {
          print("⚠️ Error: Arguments no válidos.");
        }
      });

      // ✅ Escuchar cuando se asigna un agente
      _hubConnection.on("AgentAssigned", (arguments) {
        if (arguments != null && arguments is List<dynamic>) {
          final agentUsername = arguments[0] as String;
          _assignedSupportAgent = agentUsername;
          print("✅ Agente asignado: $_assignedSupportAgent");

          if (onAssignedSupportAgent != null) {
            onAssignedSupportAgent!(_assignedSupportAgent!);
          }
        }
      });

      // 🖊️ Escuchar eventos de escritura
      _hubConnection.on("UserTyping", (arguments) {
        if (arguments != null && arguments is List<dynamic>) {
          final username = arguments[0] as String;
          if (onUserTyping != null) onUserTyping!(username);
        }
      });

      // 🛑 Escuchar eventos de detención de escritura
      _hubConnection.on("UserStoppedTyping", (arguments) {
        if (arguments != null && arguments is List<dynamic>) {
          final username = arguments[0] as String;
          if (onUserStoppedTyping != null) onUserStoppedTyping!(username);
        }
      });

      await _connect();
    } catch (e) {
      print("❌ Error al conectar con SignalR: $e");
    }
  }

  /// Conectar con el servidor y asignar usuario
  Future<void> _connect() async {
    if (_isConnected) return;

    try {
      await _hubConnection.start();
      _isConnected = true;
      print("✅ Conectado a SignalR");

      final prefs = await SharedPreferences.getInstance();
      String userName = prefs.getString("fcUsuarioAcceso") ?? "Cliente Anónimo";

      print("🔍 Buscando agente para $userName...");

      await _hubConnection.invoke("JoinAsClient", args: [userName]);
    } catch (e) {
      print("❌ Error al conectar con SignalR: $e");
      _isConnected = false;
      Future.delayed(const Duration(seconds: 5), _reconnect);
    }
  }

  /// Reintentar conexión automáticamente
  void _reconnect() {
    if (!_isConnected) {
      print("🔄 Intentando reconectar...");
      _connect();
    }
  }

  /// Enviar mensaje
  Future<void> sendMessage(Message message) async {
    if (!_isConnected || _assignedSupportAgent == null) {
      print("⚠️ No conectado o sin agente asignado.");
      return;
    }

    try {
      await _hubConnection.invoke("SendMessage", args: [message.toJson()]);
      print("📤 Mensaje enviado a $_assignedSupportAgent: ${message.text} | Tipo: ${message.messageType}");
      _messages.add(message);
    } catch (e) {
      print("❌ Error al enviar mensaje: $e");
    }
  }

  Timer? _typingTimer;
  void sendTyping() async {
    if (_assignedSupportAgent == null) return;
    final prefs = await SharedPreferences.getInstance();
    String user = prefs.getString("fcUsuarioAcceso") ?? "Cliente Anónimo";

    await _hubConnection.invoke("Typing", args: [user]);

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      sendStopTyping();
    });
  }

  void sendStopTyping() async {
    if (_assignedSupportAgent == null) return;
    final prefs = await SharedPreferences.getInstance();
    String user = prefs.getString("fcUsuarioAcceso") ?? "Cliente Anónimo";

    _typingTimer?.cancel();
    await _hubConnection.invoke("StopTyping", args: [user]);
  }

  /// Obtener mensajes previos
  List<Message> receiveMessages() {
    return List.from(_messages);
  }

  /// Obtener el agente asignado
  String? getAssignedAgent() {
    return _assignedSupportAgent;
  }

  /// Cerrar conexión
  Future<void> stop() async {
    await _hubConnection.stop();
    _isConnected = false;
  }

  HubConnection get connection => _hubConnection;
}