import 'dart:convert';
import 'dart:io';

import 'package:app_cliente_novanet/utils/button.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Variables para selección manual
  bool _showManualSelection = false;
  String? _selectedMontoText;

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
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ip'];
      } else {
        throw Exception('Failed to get IP address');
      }
    } catch (e) {
      print('Error IP: $e');
      return 'No disponible';
    }
  }

  Future<void> sendDatos() async {
    if (_image == null) {
      CherryToast.warning(
        title: const Text('Debe subir una imagen del depósito'),
        backgroundColor: widget.notifire.getbackcolor,
      ).show(context);
      return;
    }

    if (_montoController.text.isEmpty) {
      CherryToast.warning(
        title: const Text('Debe indicar el monto'),
        backgroundColor: widget.notifire.getbackcolor,
      ).show(context);
      return;
    }

    try {
      final Uri url = Uri.parse('${apiUrl}Servicio/SubirComprobanteDeposito');
      String diaHora = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
      String hora = '${DateTime.now().hour}-${DateTime.now().minute}';

      DepositoModel model = DepositoModel(
        pcIdentidad: _identidadController.text,
        pcNombreCliente: _nombreClienteController.text,
        pcTelefonoCliente: _telefonoController.text,
        pnValordelDeposito: double.parse(_montoController.text.replaceAll(',', '')),
        pcArchivo: _image,
        pcComentarioCliente: _comentarioController.text,
        pcIP: pcIP,
        pcNombreArchivo: '${diaHora}_${hora}_${_nombreClienteController.text}.${_image!.path.split('.').last}',
      );

      var modelJson = jsonEncode({
        ...model.toJson(),
        'pcArchivo': base64Encode(await _image!.readAsBytes()),
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
        Navigator.pop(context);
        CherryToast.success(
          title: const Text('Depósito subido correctamente'),
          backgroundColor: widget.notifire.getbackcolor,
        ).show(context);
      } else {
        CherryToast.error(
          title: const Text('Error al subir el depósito'),
          backgroundColor: widget.notifire.getbackcolor,
        ).show(context);
      }
    } catch (e) {
      print('Error envío: $e');
      CherryToast.error(
        title: const Text('Error de conexión. Intente más tarde'),
        backgroundColor: widget.notifire.getbackcolor,
      ).show(context);
    }
  }

  Future<void> setDatos() async {
    final prefs = await SharedPreferences.getInstance();
    _identidadController.text = prefs.getString("fcIdentidad") ?? '';
    _nombreClienteController.text = prefs.getString("fcNombreUsuario") ?? '';
    _telefonoController.text = prefs.getString("fcTelefono") ?? '';
    if (_identidadController.text.isNotEmpty) {
      setState(() => identidad = false);
    }
  }

Future<void> _pickImage() async {
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile == null) return;

  setState(() {
    _image = File(pickedFile.path);
    _montoController.clear();
    _showManualSelection = false;
    _selectedMontoText = null;
  });

  // Directo a manual, ya que no hay OCR confiable sin ML Kit
  _showManualMontoSelection();
}

//   Future<void> _tryExtractFromImage() async {
//   if (_image == null) return;

//   try {
//     final controller = MobileScannerController();
//     final inputImage = InputImage.fromFilePath(_image!.path);

//     final result = await controller.analyzeImage(inputImage);

//     if (result != null && result.barcodes.isNotEmpty) {
//       final barcode = result.barcodes.first;
//       final code = barcode.rawValue ?? '';
//       final possibleMonto = _extractNumberFromString(code);

//       if (possibleMonto != null && possibleMonto > 0) {
//         setState(() {
//           _montoController.text = _formatMonetaryOutput(possibleMonto);
//         });
//         CherryToast.success(
//           title: Text('Monto detectado: L ${_formatMonetaryOutput(possibleMonto)}'),
//           backgroundColor: widget.notifire.getbackcolor,
//         ).show(context);
//         controller.dispose();
//         return;
//       }
//     }

//     controller.dispose();
//     _showManualMontoSelection();

//   } catch (e) {
//     print("Error análisis: $e");
//     _showManualMontoSelection();
//   }
// }

  double? _extractNumberFromString(String text) {
    final clean = text.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean);
  }

  String _cleanMonetaryString(String input) {
    return input
        .replaceAll(RegExp(r'[^\d.,]'), '')
        .replaceAllMapped(RegExp(r'\.(\d{3})'), (m) => m[1]!)
        .replaceAllMapped(RegExp(r',(\d{3})'), (m) => m[1]!);
  }

  String _formatMonetaryOutput(double value) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(value);
  }

  // Diálogo de selección manual (mantengo tu implementación original)
  void _showManualMontoSelection() {
    setState(() => _showManualSelection = true);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: widget.notifire.getbackcolor,
          title: Text('Selecciona el monto', style: TextStyle(color: widget.notifire.getdarkscolor)),
          content: Text(
            'No se pudo detectar automáticamente el monto.\nPor favor ingréselo manualmente.',
            style: TextStyle(color: widget.notifire.getdarkscolor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showManualEntryOption();
              },
              child: Text('Ingresar manualmente', style: TextStyle(color: widget.notifire.getorangeprimerycolor)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showManualEntryOption() {
    final manualController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: widget.notifire.getbackcolor,
          title: Text('Ingresar monto manualmente', style: TextStyle(color: widget.notifire.getdarkscolor)),
          content: TextField(
            controller: manualController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Monto en Lempiras',
              prefixText: 'L ',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                final text = manualController.text.trim();
                final clean = _cleanMonetaryString(text);
                final value = double.tryParse(clean.replaceAll(',', ''));

                if (value != null && value > 0) {
                  setState(() {
                    _montoController.text = _formatMonetaryOutput(value);
                    _showManualSelection = false;
                  });
                  Navigator.pop(context);
                  CherryToast.success(
                    title: Text('Monto establecido: L ${_formatMonetaryOutput(value)}'),
                    backgroundColor: widget.notifire.getbackcolor,
                  ).show(context);
                } else {
                  CherryToast.error(
                    title: const Text('Monto inválido'),
                    backgroundColor: widget.notifire.getbackcolor,
                  ).show(context);
                }
              },
              child: Text('Aceptar', style: TextStyle(color: widget.notifire.getorangeprimerycolor)),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: widget.notifire.getdarkscolor),
      hintStyle: TextStyle(color: widget.notifire.getdarkscolor.withOpacity(0.6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: widget.notifire.getorangeprimerycolor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: widget.notifire.getprimerycolor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Registro de Depósito Bancario',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Gilroy Bold',
            color: widget.notifire.getdarkscolor,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: widget.notifire.getbackcolor,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.all(8),
         
            child: Icon(Icons.arrow_back, color: widget.notifire.getdarkscolor),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreClienteController,
                  decoration: _customInputDecoration('Nombre'),
                  style: TextStyle(color: widget.notifire.getdarkscolor),
                  enabled: false,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _identidadController,
                  decoration: _customInputDecoration('Identidad'),
                  style: TextStyle(color: widget.notifire.getdarkscolor),
                  keyboardType: TextInputType.number,
                  enabled: identidad,
                  validator: (v) => v?.isEmpty ?? true ? 'La identidad es obligatoria' : null,
                ),
                const SizedBox(height: 20),

                // Área de imagen
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
                        ? const Center(
                            child: Text(
                              'Toque para subir la imagen del depósito',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(_image!, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _image = null;
                                      _montoController.clear();
                                      _showManualSelection = false;
                                      _selectedMontoText = null;
                                    });
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 16,
                                    child: Icon(Icons.close, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (_image == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'La imagen es obligatoria',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),

                // Indicador de selección manual
                if (_showManualSelection && _image != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No se detectó monto automáticamente. Seleccione manualmente.',
                              style: TextStyle(color: Colors.orange[900]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
                TextFormField(
                  controller: _telefonoController,
                  decoration: _customInputDecoration('Número de Teléfono'),
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: widget.notifire.getdarkscolor),
                  validator: (v) => v?.isEmpty ?? true ? 'El teléfono es obligatorio' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _montoController,
                  decoration: _customInputDecoration('Monto (L)'),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: widget.notifire.getdarkscolor),
                  validator: (v) => v?.isEmpty ?? true ? 'Ingrese el monto' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _comentarioController,
                  decoration: _customInputDecoration('Comentario'),
                  style: TextStyle(color: widget.notifire.getdarkscolor),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      sendDatos();
                    } else {
                      CherryToast.warning(
                        title: const Text('Complete los campos requeridos'),
                        backgroundColor: widget.notifire.getbackcolor,
                      ).show(context);
                    }
                  },
                  child: Custombutton.button(
                    widget.notifire.getorangeprimerycolor,
                    'Realizar Registro',
                    width / 1.5,
                    icon: Icons.attach_money_rounded,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}