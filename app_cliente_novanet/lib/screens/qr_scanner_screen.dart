// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:app_cliente_novanet/api.dart';
import 'package:app_cliente_novanet/login/confirmpin.dart';
import 'package:app_cliente_novanet/service/usuarioService.dart';
import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:app_cliente_novanet/utils/button.dart';
import 'package:app_cliente_novanet/utils/media.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:http/http.dart' as http;

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({Key? key}) : super(key: key);

  @override
  _QrCodeScannerState createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  late ColorNotifire notifire;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  Future<void> IdentidadRegistro(pcIdentidadCliente) async {
    try {
      final response = await http.get(Uri.parse(
          '${apiUrl}Login/IdentidadRegistro?pcIdentidadCliente=$pcIdentidadCliente'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data is List && data.isNotEmpty) {
          final fcCorreo = data[0]?["fcCorreo"];
          final fcNombre = data[0]?["fcNombre"];
          final fiIDEquifax = data[0]?['fiIDEquifax'];
          final usuarioExiste = data[0]?['usuarioExiste'];

          // if (fcCorreo == 'SI') {
          //   CherryToast.info(
          //     backgroundColor: notifire.getbackcolor,
          //     title: Text(
          //       'Ya cuenta con un Usuario Secundario',
          //       style: TextStyle(color: notifire.getdarkscolor),
          //       textAlign: TextAlign.start,
          //     ),
          //     borderRadius: 5,
          //   ).show(context);
          // } else {
            String tokenAPI = await fetchTokenAPI(
              context,
              notifire.getbackcolor,
              notifire.getdarkscolor,
              fcCorreo,
            );

            if (tokenAPI.isEmpty) {
              CherryToast.error(
                backgroundColor: notifire.getbackcolor,
                title: Text(
                  'Ha Ocurrido un Error Inesperado',
                  style: TextStyle(color: notifire.getdarkscolor),
                  textAlign: TextAlign.start,
                ),
                borderRadius: 5,
              ).show(context);
              return;
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmPin(
                  tokenAPI: tokenAPI,
                  fiIDEquifax: fiIDEquifax,
                  backColor: notifire.getbackcolor,
                  darkColor: notifire.getdarkscolor,
                ),
              ),
            );
          // }
        } else {
          CherryToast.warning(
            backgroundColor: notifire.getbackcolor,
            title: Text(
              'QR no valido',
              style: TextStyle(color: notifire.getdarkscolor),
              textAlign: TextAlign.start,
            ),
            borderRadius: 5,
          ).show(context);
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {}
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
          'Escanear Código QR',
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
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: notifire.getorangeprimerycolor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: qrText != null
                    ? GestureDetector(
                        onTap: () {
                           IdentidadRegistro(qrText);
                        },
                        child: Custombutton.button(
                            notifire.getorangeprimerycolor,
                            'Crear Usuario Secundario',
                            width / 2),
                      )
                    : Text(
                        'Escanea el código QR \n compartido por el Usuario Principal',
                        style: TextStyle(
                          color: notifire.getorangeprimerycolor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData.code;
      });
     
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
