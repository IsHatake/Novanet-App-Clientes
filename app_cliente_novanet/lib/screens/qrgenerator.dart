// ignore_for_file: unused_element

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart'; // Importamos share_plus
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cherry_toast/cherry_toast.dart';

class QrCodeGenerator extends StatefulWidget {
  const QrCodeGenerator({Key? key}) : super(key: key);

  @override
  _QrCodeGeneratorState createState() => _QrCodeGeneratorState();
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> {
  late ColorNotifire notifire;
  final GlobalKey _globalKey = GlobalKey();
  late String fcIdentidad = '';

  @override
  void initState() {
    super.initState();
    getDarkModePreviousState();
  }

  Future<void> getDarkModePreviousState() async {
    final prefs = await SharedPreferences.getInstance();
    final previousState = prefs.getBool("setIsDark") ?? false;
    notifire.setIsDark = previousState;

    String Identidad = prefs.getString("fcIdentidad") ?? '';
    setState(() {
      fcIdentidad = Identidad;
    });
  }

  Future<void> _captureAndSharePng() async {
  try {
  // Capturar la imagen del QR
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Guardar temporalmente
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/qr_code_novanet.png');
    await file.writeAsBytes(pngBytes);

    final String shareText = 'Descarga la Aplicación de Novanet\n'
        'Play Store : https://play.google.com/store/apps/details?id=com.prestaditonovanet.novanet\n\n'
        'App Store : https://apps.apple.com/hn/app/novanet/id6736670238\n\n'
        'O escanea este QR para registrarte como usuario familiar.';

    if (Platform.isIOS) {
      // Obtener posición y tamaño real del contenedor QR (esto soluciona el error)
      final RenderBox box = _globalKey.currentContext!.findRenderObject() as RenderBox;
      final Offset position = box.localToGlobal(Offset.zero);
      final Size size = box.size;

      // Rectángulo de origen válido (centro del QR)
      final Rect shareOrigin = Rect.fromCenter(
        center: Offset(position.dx + size.width / 2, position.dy + size.height / 2),
        width: size.width,
        height: size.height,
      );

      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareText,
        subject: 'Código QR Novanet',
        sharePositionOrigin: shareOrigin, // ← Esto es obligatorio en iOS
      );
    } else {
      // Android: sin posición (funciona sin problema)
      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareText,
        subject: 'Código QR Novanet',
      );
    }
  } catch (e) {
    print('Error al compartir QR: $e');
    CherryToast.error(
        title: Text('No se pudo compartir el QR'),
    
    ).show(context);
  }
}

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      backgroundColor: notifire.getprimerycolor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Comparte con Familiar',
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Gilroy Bold',
            color: notifire.getdarkscolor,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: notifire.getbackcolor,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: notifire.getwhite),
            ),
            child: Icon(Icons.arrow_back, color: notifire.getdarkscolor),
          ),
        ),
        actions: [
          // Botón de compartir visible solo en iOS
          if (Platform.isIOS)
            IconButton(
              icon: Icon(Icons.share, color: notifire.getwhite),
              onPressed: _captureAndSharePng,
            ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón de compartir (solo iOS, o puedes mostrar mensaje en Android)
          if (Platform.isIOS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: _captureAndSharePng,
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text(
                  'Compartir QR y Links de Descarga',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: notifire.getorangeprimerycolor,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (!Platform.isIOS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Función de compartir disponible solo en iOS',
                style: TextStyle(
                  color: notifire.getdarkscolor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),
          Center(
            child: RepaintBoundary(
              key: _globalKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('images/logos.png', height: 100),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: notifire.getorangeprimerycolor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Escanéame',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: notifire.getorangeprimerycolor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          QrCode(fcIdentidad: fcIdentidad),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Instrucciones:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: notifire.getorangeprimerycolor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '1. Descarga y abre la aplicación de Novanet.\n'
                      '2. Selecciona la opción de QR Usuario Familiar en el Inicio de Sesión.\n'
                      '3. El usuario familiar debe escanear el código QR mostrado arriba.\n'
                      '4. Llena el Formulario con los datos solicitados.\n'
                      '5. Ingresa el Token enviado al correo ingresado.\n',
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrCode extends StatelessWidget {
  final String fcIdentidad;

  const QrCode({Key? key, required this.fcIdentidad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data:
          'https://novanetgroup.com/NovanetApp/formulario_usuario_secundario.html?id=$fcIdentidad',
      version: QrVersions.auto,
      size: 200.0,
    );
  }
}