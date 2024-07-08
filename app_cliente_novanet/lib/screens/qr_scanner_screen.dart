// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:app_cliente_novanet/api.dart';
import 'package:app_cliente_novanet/screens/adduserFamily.dart';
import 'package:app_cliente_novanet/screens/preguntas_register.dart';
import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:app_cliente_novanet/utils/button.dart';

import 'package:app_cliente_novanet/utils/textfeilds.dart';
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

class _QrCodeScannerState extends State<QrCodeScanner>
    with SingleTickerProviderStateMixin {
  late ColorNotifire notifire;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;
  late TabController _tabController;
  final TextEditingController _identidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  Future<void> handleTap() async {
    if (_identidadController.text.isEmpty) {
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'Llene el campo vacio',
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }
    if (_identidadController.text.length < 15) {
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'Se requieren 13 dígitos como minimo para el campo de identidad',
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }
    var pcIdentidadCliente = _identidadController.text.replaceAll("-", "");
    IdentidadRegistro(pcIdentidadCliente, 'Preguntas_Screen');
  }

  Future<void> IdentidadRegistro(pcIdentidadCliente, redirige) async {
    try {
      final response = await http.get(Uri.parse(
          '${apiUrl}Login/IdentidadRegistro?pcIdentidadCliente=$pcIdentidadCliente'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data is List && data.isNotEmpty) {
          final fiIDEquifax = data[0]?['fiIDEquifax'];

          if (redirige == 'AdduserFamily') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdduserFamily(
                  fiIDEquifax: fiIDEquifax,
                  redireccion: true,
                  fbprincipal: false,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PreguntaFormScreen(
                  fcIdentidad: pcIdentidadCliente,
                  fiIDEquifax: fiIDEquifax,
                  redireccion: true,
                  fbprincipal: false,
                ),
              ),
            );
            return;
          }
        } else {
          CherryToast.warning(
            backgroundColor: notifire.getbackcolor,
            title: Text(
              'No valido',
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: notifire.getprimerycolor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Usuario Secundario',
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
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.black,
            tabs: const [
              Tab(text: "Escanear QR"),
              Tab(text: "Registrar de Forma Manual"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Column(
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
                                IdentidadRegistro(qrText, 'AdduserFamily');
                              },
                              child: Custombutton.button(
                                  notifire.getorangeprimerycolor,
                                  'Crear Usuario Secundario',
                                  MediaQuery.of(context).size.width / 2),
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
            SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.9,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.transparent,
                        child: Image.asset(
                          "images/background.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 20,
                          ),
                          Stack(
                            children: [
                              Center(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 1.22,
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  decoration: BoxDecoration(
                                    color: notifire.gettabwhitecolor,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    reverseDuration:
                                        const Duration(milliseconds: 200),
                                    switchInCurve: Curves.decelerate,
                                    switchOutCurve: Curves.decelerate,
                                    child: _buildDNIContent(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 40,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 60,
                          ),
                          Center(
                            child: Image.asset(
                              "images/logos.png",
                              height: MediaQuery.of(context).size.height / 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildTextRow(String text) {
    return Row(
      children: [
        SizedBox(width: MediaQuery.of(context).size.width / 18),
        Text(
          text,
          style: TextStyle(
            color: notifire.getdarkscolor,
            fontSize: MediaQuery.of(context).size.height / 50,
          ),
        ),
      ],
    );
  }

  Widget _buildDNIContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 15,
        ),
        _buildTextRow("Ingrese el DNI del usuario principal"),
        SizedBox(height: MediaQuery.of(context).size.height / 70),
        DNI.textField(
          notifire.getdarkscolor,
          notifire.getdarkgreycolor,
          notifire.getorangeprimerycolor,
          "images/DNI.png",
          "DNI",
          notifire.getdarkwhitecolor,
          _identidadController,
        ),
        SizedBox(height: MediaQuery.of(context).size.height / 35),
        GestureDetector(
          onTap: () {
            handleTap();
          },
          child: Custombutton.button(
            notifire.getorangeprimerycolor,
            "Verificar",
            MediaQuery.of(context).size.width / 2,
          ),
        ),
      ],
    );
  }
}
