// ignore_for_file: deprecated_member_use, avoid_print, non_constant_identifier_names

import 'dart:io';

import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
// import 'package:path_provider/path_provider.dart';

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

  // Future<void> _captureAndSharePng() async {
  //   try {
  //     RenderRepaintBoundary boundary = _globalKey.currentContext!
  //         .findRenderObject() as RenderRepaintBoundary;
  //     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  //     ByteData? byteData =
  //         await image.toByteData(format: ui.ImageByteFormat.png);
  //     Uint8List pngBytes = byteData!.buffer.asUint8List();

  //     final tempDir = await getTemporaryDirectory();
  //     final file = await File('${tempDir.path}/qr_code.png').create();
  //     await file.writeAsBytes(pngBytes);

  //     await Share.shareFiles([file.path], text: 'Descarga la Aplicación de Novanet\n'
  //                                               'https://play.google.com/store/apps/details?id=com.prestaditonovanet.novanet'         );
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      backgroundColor: notifire.getprimerycolor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Creación de Usuario Secundario',
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Gilroy Bold',
            color: notifire.getwhite,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: notifire.getorangeprimerycolor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: notifire.getwhite),
            ),
            child: Icon(Icons.arrow_back, color: notifire.getwhite),
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.share, color: notifire.getwhite),
        //     onPressed: _captureAndSharePng,
        //   ),
        // ],
      ),
      body: Center(
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
                  '1. Abre la aplicación de Novanet.\n'
                  '2. Selecciona la opcion de QR Usuario Secundario en el Inicio de Sesión.\n'
                  '3. Escanea el código QR mostrado arriba.\n'
                  '4. Llena el Formulario.\n'
                  '5. Ingresa el Token enviado al correo ingresado.\n',
                  style: TextStyle(fontSize: 15  , color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
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
      data: 'https://novanetgroup.com/NovanetApp/formulario_usuario_secundario.html?id=$fcIdentidad',
      version: QrVersions.auto,
      size: 200.0,
    );
  }
}
