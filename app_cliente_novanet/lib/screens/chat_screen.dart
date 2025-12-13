import 'dart:async';
import 'dart:io';
import 'package:app_cliente_novanet/models/MessageViewModel.dart';
import 'package:app_cliente_novanet/service/signalRChat_Service.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
class TypingIndicator extends StatefulWidget {
  /// El color de los puntos del indicador.
  final Color dotColor;

  /// El tamaño máximo de los puntos.
  final double dotSize;

  /// El espaciado entre los puntos.
  final double spacing;

  /// La duración de un ciclo completo de la animación.
  final Duration animationDuration;

  const TypingIndicator({Key? key, 
    this.dotColor = Colors.grey,
    this.dotSize = 10.0,
    this.spacing = 6.0,
    this.animationDuration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  TypingIndicatorState createState() => TypingIndicatorState();
}

class TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador de animación
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    // Crear una animación base que va de 0 a 1 con un efecto de rebote
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
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
            _buildDot(_getScale(0.0)),
            SizedBox(width: widget.spacing),
            _buildDot(_getScale(0.2)),
            SizedBox(width: widget.spacing),
            _buildDot(_getScale(0.4)),
          ],
        );
      },
    );
  }

  /// Construye un punto con el tamaño y color especificados.
  Widget _buildDot(double scale) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.dotSize,
        height: widget.dotSize,
        decoration: BoxDecoration(
          color: widget.dotColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.dotColor.withOpacity(0.3),
              blurRadius: 3,
              spreadRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  /// Calcula la escala del punto según el desplazamiento de la animación.
  /// [offset] determina el retraso de la animación para cada punto.
  double _getScale(double offset) {
    // Mapear el valor de la animación (0 a 1) al rango de escala (0.6 a 1.0)
    final progress = (_animation.value + offset) % 1.0;
    return 0.6 + (0.4 * (1 - (progress - 0.5).abs() * 2));
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
  late FocusNode _textFieldFocusNode;
  late String _username;
  String? _assignedSupportAgent;
  late ColorNotifire notifire;
  bool _isTyping = false;
  Timer? _typingDebounce;
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _fileList = [];
  bool _isDragging = false;
  late String _conversationId;

  @override
  void initState() {
    super.initState();
    _textFieldFocusNode = FocusNode();
    _initializeScreen();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });

    widget.chatSignalRService.onMessageReceived = (message) {
      setState(() {
        messages.add(message);
        _scrollToBottom();
      });
    };

    widget.chatSignalRService.onAssignedSupportAgent = (agent) {
      print("Agente asignado recibido: $agent");
      setState(() {
        _assignedSupportAgent = agent;
        _updateConversationId();
      });
    };

    widget.chatSignalRService.onUserTyping = (username) {
      if (username == _assignedSupportAgent) {
        setState(() {
          _isTyping = true;
          _scrollToBottom();
        });
      }
    };

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
      _updateConversationId();
      _scrollToBottom();
    });
  }

  void _updateConversationId() {
    final dateFormat = DateFormat('dd-MM-yyyy');
    final chatDate = dateFormat.format(DateTime.now());
    final agent = _assignedSupportAgent ?? "pending";
    _conversationId = "chat_${_username}_${chatDate}";
    print("Conversation ID generado: $_conversationId");
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

  Future<void> _pickFiles() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seleccionar archivo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.photo_library,
                    label: 'Fotos y videos',
                    color: Colors.blue,
                    onTap: () async {
                      Navigator.pop(context);
                      final files = await _picker.pickMultiImage();
                      if (files != null && files.isNotEmpty) {
                        _addFilesToList(files);
                      }
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.camera_alt,
                    label: 'Cámara',
                    color: Colors.green,
                    onTap: () async {
                      Navigator.pop(context);
                      final file = await _picker.pickImage(source: ImageSource.camera);
                      if (file != null) {
                        _addFilesToList([file]);
                      }
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.insert_drive_file,
                    label: 'Documento',
                    color: Colors.purple,
                    onTap: () async {
                      Navigator.pop(context);
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                        type: FileType.any,
                      );
                      if (result != null) {
                        final files = result.files.map((file) => XFile(file.path!)).toList();
                        _addFilesToList(files);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _addFilesToList(List<XFile> files) {
    if (_fileList.length + files.length > 5) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Límite Excedido'),
          content: const Text('Puedes seleccionar un máximo de 5 archivos.'),
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

    _fileList.addAll(files);
    setState(() {});
  }

  Future<Map<String, dynamic>?> _uploadFile(XFile file) async {
    try {
      final uri = Uri.parse("https://ptdto.com/ChatOrion/api/Upload/SubirArchivo")
          .replace(queryParameters: {'conversationId': _conversationId});

      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        print("✅ Archivo subido exitosamente: $responseData");
        return jsonDecode(responseData);
      } else {
        print("❌ Error al subir archivo: ${response.statusCode} - ${response.reasonPhrase}");
        final errorData = await response.stream.bytesToString();
        print("Detalles del error: $errorData");
        return null;
      }
    } catch (e) {
      print("❌ Error al subir archivo: $e");
      return null;
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty && _fileList.isEmpty) return;

    if (_fileList.isNotEmpty) {
      for (var file in _fileList) {
        final uploadResult = await _uploadFile(file);
        if (uploadResult != null) {
          final message = Message(
            senderId: _username,
            receiverId: _assignedSupportAgent,
            text: text.isNotEmpty ? text : "",
            fileUrl: uploadResult['fileUrl'],
            fileName: uploadResult['fileName'],
            contentType: uploadResult['contentType'],
            messageType: "File",
            date: DateTime.now(),
          );
          await widget.chatSignalRService.sendMessage(message);
        }
      }
      _controller.clear();
      _fileList.clear();
      setState(() {});
    } else if (text.isNotEmpty) {
      final message = Message(
        senderId: _username,
        receiverId: _assignedSupportAgent,
        text: text,
        messageType: "Text",
        date: DateTime.now(),
      );
      await widget.chatSignalRService.sendMessage(message);
      _controller.clear();
    }
    _scrollToBottom();
  }

  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.9,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el archivo')),
      );
    }
  }

  // Método para obtener un ícono según el tipo de archivo
  IconData _getFileIcon(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_fields;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Método para determinar si un archivo es una imagen basado en su extensión o contentType
  bool _isImageFile(Message message) {
    // Verificar primero el contentType
    if (message.contentType != null && message.contentType!.startsWith('image/')) {
      return true;
    }
    // Si no hay contentType, verificar la extensión del fileName
    if (message.fileName != null) {
      final extension = message.fileName!.toLowerCase().split('.').last;
      return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
    }
    return false;
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
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
                    onLongPress: () => message.text?.isNotEmpty ?? false ? _copyMessage(message.text!) : null,
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
                            if (message.messageType == "File" && message.fileUrl != null)
                              _isImageFile(message) // Usar el nuevo método para determinar si es una imagen
                                  ? GestureDetector(
                                      onTap: () => _showFullImage(message.fileUrl!),
                                      child: CachedNetworkImage(
                                        imageUrl: message.fileUrl!,
                                        width: 200,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () => _launchUrl(message.fileUrl!),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getFileIcon(message.fileName ?? ''),
                                            size: 20,
                                            color: isClientMessage ? Colors.white : Colors.blue,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            message.fileName ?? "Descargar archivo",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: isClientMessage ? Colors.white : Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
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
                if (_fileList.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _fileList.length,
                            itemBuilder: (context, index) {
                              final file = _fileList[index];
                              final isImage = file.path.toLowerCase().endsWith('.jpg') ||
                                  file.path.toLowerCase().endsWith('.jpeg') ||
                                  file.path.toLowerCase().endsWith('.png') ||
                                  file.path.toLowerCase().endsWith('.gif');

                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Draggable<int>(
                                  data: index,
                                  feedback: isImage
                                      ? Image.file(
                                          File(file.path),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          opacity: const AlwaysStoppedAnimation(0.7),
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[300],
                                            child: const Center(child: Icon(Icons.error, color: Colors.red)),
                                          ),
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  _getFileIcon(file.path),
                                                  size: 40,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  file.name,
                                                  style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  childWhenDragging: Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                  ),
                                  onDragStarted: () => setState(() => _isDragging = true),
                                  onDragEnd: (details) => setState(() => _isDragging = false),
                                  child: isImage
                                      ? Image.file(
                                          File(file.path),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[300],
                                            child: const Center(child: Icon(Icons.error, color: Colors.red)),
                                          ),
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  _getFileIcon(file.path),
                                                  size: 40,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  file.name,
                                                  style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
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
                                _fileList.removeAt(index);
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
                        focusNode: _textFieldFocusNode,
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
                            onPressed: _pickFiles,
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