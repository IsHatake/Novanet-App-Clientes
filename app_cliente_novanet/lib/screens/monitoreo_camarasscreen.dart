import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class CameraScreen extends StatefulWidget {
  final String rtspUrl;
  final String cameraName;

  const CameraScreen({
    Key? key,
    required this.rtspUrl,
    required this.cameraName,
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late VlcPlayerController _vlcController;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _vlcController = VlcPlayerController.network(
      widget.rtspUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(300),
          VlcAdvancedOptions.liveCaching(300),
        ]),
        video: VlcVideoOptions([
          VlcVideoOptions.dropLateFrames(true),
          VlcVideoOptions.skipFrames(true),
        ]),
        extras: [
          '--rtsp-tcp',        // ¡¡CRUCIAL!! Forzar TCP para evitar lag y desconexiones en WiFi
          '--no-lua',          // Desactivar scripts innecesarios
          '--no-sout-all',
          '--sout-keep',
        ],
      ),
    );

    // Listener de inicialización
    _vlcController.addOnInitListener(() {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });

    // Listener principal para estado y errores
    _vlcController.addListener(() {
      if (!mounted) return;

      final value = _vlcController.value;

      setState(() {
        _isPlaying = value.isPlaying;
      });

      // Detectar errores (cuando hay descripción de error)
      if (value.errorDescription != null && value.errorDescription!.isNotEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = value.errorDescription!;
        });
        debugPrint('VLC Error: ${value.errorDescription}');
      }
    });
  }

  void _togglePlayPause() {
    if (_vlcController.value.isPlaying) {
      _vlcController.pause();
    } else {
      _vlcController.play();
    }
  }

  void _retryConnection() {
    setState(() {
      _hasError = false;
      _isInitialized = false;
    });
    _vlcController.dispose();
    _initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.cameraName),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _isInitialized ? _togglePlayPause : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _retryConnection,
            tooltip: 'Reintentar conexión',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Video player
          Center(
            child: _isInitialized
                ? VlcPlayer(
                    controller: _vlcController,
                    aspectRatio: 16 / 9,
                    placeholder: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Conectando a la cámara...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),

          // Mensaje de error
          if (_hasError)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Error de conexión',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _retryConnection,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),

          // Indicador de estado en vivo
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isPlaying ? Icons.videocam : Icons.videocam_off,
                    color: _isPlaying ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isPlaying ? 'En vivo' : 'Desconectado',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _vlcController.dispose();
    super.dispose();
  }
}