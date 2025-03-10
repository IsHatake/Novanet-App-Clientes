import 'dart:async';
import 'package:app_cliente_novanet/models/MessageViewModel.dart';
import 'package:app_cliente_novanet/service/signalRChat_Service.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dot1Animation;
  late Animation<double> _dot2Animation;
  late Animation<double> _dot3Animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _dot1Animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeInOut)),
    );
    _dot2Animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeInOut)),
    );
    _dot3Animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(_dot1Animation.value),
            const SizedBox(width: 6),
            _buildDot(_dot2Animation.value),
            const SizedBox(width: 6),
            _buildDot(_dot3Animation.value),
          ],
        );
      },
    );
  }

  Widget _buildDot(double scale) {
    return Container(
      width: 10 * scale,
      height: 10 * scale,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        shape: BoxShape.circle,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final ChatSignalRService chatSignalRService;

  const ChatScreen({Key? key, required this.chatSignalRService}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();
  late String _username;
  String? _assignedSupportAgent;
  late ColorNotifire notifire;
  bool _isTyping = false;
  Timer? _typingDebounce;
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  List<String> _imageBase64List = [];
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();

    // Configurar el callback para cuando se recibe un mensaje
    widget.chatSignalRService.onMessageReceived = (message) {
      setState(() {
        messages.add(message);
        _scrollToBottom();
      });
    };

    // Configurar el callback para cuando se asigna un agente
    widget.chatSignalRService.onAssignedSupportAgent = (agent) {
      print("Agente asignado recibido: $agent");
      setState(() {
        _assignedSupportAgent = agent;
      });
    };

    // Configurar el callback para cuando el agente está escribiendo
    widget.chatSignalRService.onUserTyping = (username) {
      if (username == _assignedSupportAgent) {
        setState(() {
          _isTyping = true;
          _scrollToBottom();
        });
      }
    };

    // Configurar el callback para cuando el agente deja de escribir
    widget.chatSignalRService.onUserStoppedTyping = (username) {
      if (username == _assignedSupportAgent) {
        setState(() => _isTyping = false);
      }
    };
  }

  Future<void> _initializeScreen() async {
    await _loadDataUser();
    setState(() {
      messages = widget.chatSignalRService.receiveMessages();
      _assignedSupportAgent = widget.chatSignalRService.getAssignedAgent();
      print("Agente asignado inicial: $_assignedSupportAgent");
      _scrollToBottom();
    });
  }

  void _onTextChanged(String text) {
    if (_typingDebounce?.isActive ?? false) _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(milliseconds: 500), () {
      widget.chatSignalRService.sendStopTyping();
    });
    widget.chatSignalRService.sendTyping();
  }

  Future<void> _loadDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("fcUsuarioAcceso") ?? "Cliente Anónimo";
    });
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      if (images.length > 5) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Límite Excedido'),
            content: const Text('Puedes seleccionar un máximo de 5 imágenes.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      _imageBase64List.clear();
      for (var image in images) {
        final compressedBytes = await FlutterImageCompress.compressWithList(
          await image.readAsBytes(),
          minHeight: 800,
          minWidth: 800,
          quality: 50,
          format: CompressFormat.jpeg,
        );
        final base64String = "data:image/jpeg;base64,${base64Encode(compressedBytes)}";
        _imageBase64List.add(base64String);
      }
      setState(() {});
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();

    if (text.isEmpty && _imageBase64List.isEmpty) {
      return; // No hay nada que enviar
    }

    if (_imageBase64List.isNotEmpty) {
      for (var base64String in _imageBase64List) {
        final message = Message(
          senderId: _username,
          receiverId: _assignedSupportAgent,
          text: text.isNotEmpty ? text : "",
          base64Content: base64String,
          messageType: "Image",
          date: DateTime.now(),
        );
        widget.chatSignalRService.sendMessage(message);
      }
      _controller.clear();
      _imageBase64List.clear();
      setState(() {});
    } else if (text.isNotEmpty) {
      final message = Message(
        senderId: _username,
        receiverId: _assignedSupportAgent,
        text: text,
        base64Content: "",
        messageType: "Text",
        date: DateTime.now(),
      );
      widget.chatSignalRService.sendMessage(message);
    }
    _scrollToBottom();
  }

  void _showFullImage(String base64Content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.memory(
                  base64Decode(base64Content.split(',').last),
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.9,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mensaje copiado al portapapeles')),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifire.getorangeprimerycolor,
        title: Text(
          _assignedSupportAgent != null ? "Chat con $_assignedSupportAgent" : "Esperando soporte...",
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: notifire.getprimerycolor,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TypingIndicator(),
                      ),
                    );
                  }

                  final message = messages[index];
                  final isClientMessage = message.senderId == _username;
                  return GestureDetector(
                    onLongPress: () => message.text!.isNotEmpty ? _copyMessage(message.text!) : null,
                    child: Align(
                      alignment: isClientMessage ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isClientMessage ? notifire.getorangeprimerycolor : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.senderId!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isClientMessage ? Colors.white : Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (message.messageType == "Text" && message.text != null)
                              Text(
                                message.text!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isClientMessage ? Colors.white : Colors.grey[800],
                                ),
                              ),
                            if (message.messageType == "Image" && message.base64Content != null)
                              GestureDetector(
                                onTap: () => _showFullImage(message.base64Content!),
                                child: Image.memory(
                                  base64Decode(message.base64Content!.split(',').last),
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: notifire.getbackcolor,
            child: Column(
              children: [
                if (_imageBase64List.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imageBase64List.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Draggable<int>(
                                  data: index,
                                  feedback: Image.memory(
                                    base64Decode(_imageBase64List[index].split(',').last),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    opacity: const AlwaysStoppedAnimation(0.7),
                                  ),
                                  childWhenDragging: Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                  ),
                                  onDragStarted: () {
                                    setState(() {
                                      _isDragging = true;
                                    });
                                  },
                                  onDragEnd: (details) {
                                    setState(() {
                                      _isDragging = false;
                                    });
                                  },
                                  child: GestureDetector(
                                    onTap: () => _showFullImage(_imageBase64List[index]),
                                    child: Image.memory(
                                      base64Decode(_imageBase64List[index].split(',').last),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (_isDragging)
                          DragTarget<int>(
                            onAccept: (index) {
                              setState(() {
                                _imageBase64List.removeAt(index);
                                _isDragging = false;
                              });
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: candidateData.isNotEmpty ? Colors.red[700] : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: _onTextChanged,
                        autofocus: false,
                        style: TextStyle(fontSize: 16, color: notifire.getdarkscolor),
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          hintStyle: TextStyle(color: notifire.getdarkscolor),
                          labelStyle: TextStyle(color: notifire.getdarkscolor),
                          filled: true,
                          fillColor: notifire.getprimerycolor,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: notifire.getorangeprimerycolor),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xffd3d3d3)),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          prefixIcon: IconButton(
                            icon: Icon(Icons.attach_file, color: notifire.getdarkscolor),
                            onPressed: _pickImages,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: notifire.getorangeprimerycolor,
                      onPressed: _sendMessage,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}