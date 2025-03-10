import 'dart:convert';

import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:app_cliente_novanet/utils/button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:app_cliente_novanet/api.dart';
class DepositoModel {
  String pcIdentidad;
  String pcNombreCliente;
  String pcTelefonoCliente;
  double pnValordelDeposito;
  File? pcArchivo;
  String pcComentarioCliente;
  String pcIP;
  String? pcNombreArchivo;

  DepositoModel({
    required this.pcIdentidad,
    required this.pcNombreCliente,
    required this.pcTelefonoCliente,
    required this.pnValordelDeposito,
    required this.pcArchivo,
    required this.pcComentarioCliente,
    required this.pcIP,
    this.pcNombreArchivo,
  });

  Map<String, dynamic> toJson() {
    return {
      'pcIdentidad': pcIdentidad,
      'pcNombreCliente': pcNombreCliente,
      'pcTelefonoCliente': pcTelefonoCliente,
      'pnValordelDeposito': pnValordelDeposito,
      'pcArchivo': pcArchivo,
      'pcComentarioCliente': pcComentarioCliente,
      'pcIP': pcIP,
      'pcNombreArchivo': pcNombreArchivo,
    };
  }
}

class RegistroDepositoScreen extends StatefulWidget {
  final dynamic notifire;

  const RegistroDepositoScreen({Key? key, required this.notifire})
      : super(key: key);

  @override
  _RegistroDepositoScreenState createState() => _RegistroDepositoScreenState();
}

class _RegistroDepositoScreenState extends State<RegistroDepositoScreen> {
  File? _image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _identidadController = TextEditingController();
  final _nombreClienteController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _comentarioController = TextEditingController();
  bool identidad = true;
  String pcIP = '';
  String? pcNombreArchivo;

  @override
  void initState() {
    super.initState();
    setDatos();
    _getIPAddress().then((ip) {
      setState(() {
        pcIP = ip;
      });
    });
  }

  Future<String> _getIPAddress() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ip'];
      } else {
        throw Exception('Failed to get IP address');
      }
    } catch (e) {
      throw Exception('Failed to get IP address: $e');
    }
  }
  
  Future<void> sendDatos() async {
    try {
      final Uri url = Uri.parse('$apiUrl/Servicio/SubirComprobanteDeposito');
      String diaHora = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
      String hora = '${DateTime.now().hour}-${DateTime.now().minute}';

      DepositoModel model = DepositoModel(
        pcIdentidad: _identidadController.text,
        pcNombreCliente: _nombreClienteController.text,
        pcTelefonoCliente: _telefonoController.text,
        pnValordelDeposito: double.parse(_montoController.text.replaceAll(r',', '')),
        pcArchivo: _image,
        pcComentarioCliente: _comentarioController.text,
        pcIP: pcIP,
        pcNombreArchivo: '${diaHora}_${hora}_${_nombreClienteController.text}.${_image!.path.split('.').last}',
      );

      var modelJson = jsonEncode({
        ...model.toJson(),
        'pcArchivo': _image != null ? base64Encode(_image!.readAsBytesSync()) : null,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: modelJson,
      );
      
      if (response.statusCode == 200) {
        CherryToast.success(
          backgroundColor: widget.notifire.getbackcolor,
          title: Text('Deposito subido correctamente',
              style: TextStyle(color: widget.notifire.getdarkscolor),
              textAlign: TextAlign.start),
          borderRadius: 5,
        ).show(context);
      } else {
        CherryToast.error(
          backgroundColor: widget.notifire.getbackcolor,
          title: Text('Ha ocurrido un error Inesperado',
              style: TextStyle(color: widget.notifire.getdarkscolor),
              textAlign: TextAlign.start),
          borderRadius: 5,
        ).show(context);
      }
    } catch (e) {
      CherryToast.error(
        backgroundColor: widget.notifire.getbackcolor,
        title: Text('Contactenos para mas Información',
            style: TextStyle(color: widget.notifire.getdarkscolor),
            textAlign: TextAlign.start),
        borderRadius: 5,
      ).show(context);
    }
  }

  Future<void> setDatos() async {
    final prefs = await SharedPreferences.getInstance();
    String? fcIdentidad = prefs.getString("fcIdentidad");
    String? fcNombreUsuario = prefs.getString("fcNombreUsuario");
    String? fcNumeroTelefono = prefs.getString("fcTelefono");

    _identidadController.text = fcIdentidad ?? '';
    _nombreClienteController.text = fcNombreUsuario ?? '';
    _telefonoController.text = fcNumeroTelefono ?? '';
    if (_identidadController.text.isNotEmpty) {
      setState(() {
        identidad = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _extractTextFromImage();
    }
  }

  Future<void> _extractTextFromImage() async {
    if (_image == null) return;

    final inputImage = InputImage.fromFile(_image!);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      String? monto;

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text;

          if (monto == null &&
              text.contains(RegExp(r'HNL|L\s?\d{1,3}(,\d{3})*(\.\d{2})?'))) {
            monto = text.replaceAll(RegExp(r'[^\d.,]'), '');
          }
        }
      }
      _montoController.clear();

      setState(() {
        if (monto != null) _montoController.text = monto;
      });
    } finally {
      await textRecognizer.close();
    }
  }

  InputDecoration _customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      hintStyle: TextStyle(color: widget.notifire.getdarkscolor),
      labelStyle: TextStyle(color: widget.notifire.getdarkscolor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide:
            BorderSide(color: widget.notifire.getorangeprimerycolor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: widget.notifire.getbackcolor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Registro de Depósito Bancario',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Gilroy Bold',
            color: widget.notifire.getwhite,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: widget.notifire.getorangeprimerycolor,
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
              border: Border.all(color: widget.notifire.getwhite),
            ),
            child: Icon(Icons.arrow_back, color: widget.notifire.getwhite),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreClienteController,
                  decoration: _customInputDecoration('Nombre'),
                  style: TextStyle(color: widget.notifire.getdarkscolor),
                  keyboardType: TextInputType.text,
                  enabled: false,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _identidadController,
                  decoration: _customInputDecoration('Identidad'),
                  style: TextStyle(color: widget.notifire.getdarkscolor),
                  keyboardType: TextInputType.number,
                  enabled: identidad,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La identidad es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: widget.notifire.getdarkscolor),
                      color: widget.notifire.getprimerycolor,
                    ),
                    child: _image == null
                        ? Center(
                            child: Text(
                              'Toque para subir la imagen del depósito',
                              style: TextStyle(
                                  color: widget.notifire.getdarkscolor),
                            ),
                          )
                        : Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(
                                    _image!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _image = null;
                                      _montoController.clear();
                                    });
                                  },
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 15,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (_image == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'La imagen es obligatoria',
                      style: TextStyle(color: widget.notifire.getdarkscolor),
                    ),
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _telefonoController,
                  style: TextStyle(color: widget.notifire.getdarkscolor),

                  decoration: _customInputDecoration('Número de Teléfono'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El número de teléfono es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _montoController,
                  decoration: _customInputDecoration('Monto'),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: widget.notifire.getdarkscolor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el monto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _comentarioController,
                  decoration: _customInputDecoration('Comentario'),
                  style: TextStyle(color: widget.notifire.getdarkscolor),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      sendDatos();
                    } else {
                      CherryToast.warning(
                        backgroundColor: widget.notifire.getbackcolor,
                        title: Text('Campos Vacios',
                            style:
                                TextStyle(color: widget.notifire.getdarkscolor),
                            textAlign: TextAlign.start),
                        borderRadius: 5,
                      ).show(context);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Custombutton.button(
                        widget.notifire.getorangeprimerycolor,
                        'Realizar Registro',
                        width / 1.5,
                        icon: Icons.attach_money_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
