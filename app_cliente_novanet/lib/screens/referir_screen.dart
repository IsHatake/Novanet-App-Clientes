import 'dart:convert';
import 'package:app_cliente_novanet/api.dart';
import 'package:app_cliente_novanet/utils/button.dart';
import 'package:app_cliente_novanet/utils/media.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../toastconfig/toastconfig.dart';

class ReferirScreen extends StatefulWidget {
  const ReferirScreen({Key? key}) : super(key: key);

  @override
  _ReferirScreenState createState() => _ReferirScreenState();
}

class _ReferirScreenState extends State<ReferirScreen> {
  late ColorNotifire notifire;
  final TextEditingController name = TextEditingController();
  final TextEditingController numberphone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: notifire.getprimerycolor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Referir',
          style: TextStyle(
            fontFamily: 'Gilroy Bold',
            fontSize: height * 0.025,
            color: notifire.getbackcolor,
          ),
        ),
        backgroundColor: notifire.getorangeprimerycolor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: notifire.getbackcolor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: notifire.getprimerycolor,
        padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.02),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'images/referidos.png',
                height: height * 0.25,
                width: height * 0.25,
              ),
              SizedBox(height: height * 0.03),
              Text(
                '¡Invita a un amigo!',
                style: TextStyle(
                  fontFamily: 'Gilroy Bold',
                  fontSize: height * 0.028,
                  color: notifire.getdarkscolor,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                'Comparte los beneficios con alguien que conoces',
                style: TextStyle(
                  fontFamily: 'Gilroy Medium',
                  fontSize: height * 0.018,
                  color: notifire.getdarkscolor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.04),
              _buildTextField(
                controller: name,
                label: 'Nombre del Referido',
                icon: Icons.person,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: height * 0.02),
              _buildTextField(
                controller: numberphone,
                label: 'Número de Teléfono',
                icon: Icons.phone,
                keyboardType: TextInputType.number,
                maxLength: 8,
              ),
              SizedBox(height: height * 0.04),
              GestureDetector(
                onTap: _validarYEnviar,
                child: Custombutton.button(
                  notifire.getorangeprimerycolor,
                  'Confirmar',
                  width * 0.9,
                  
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: TextStyle(color: notifire.getdarkscolor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: notifire.getdarkscolor.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: notifire.getorangeprimerycolor),
        filled: true,
        fillColor: notifire.getbackcolor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: notifire.getorangeprimerycolor, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.04),
      ),
    );
  }

  Future<void> _validarYEnviar() async {
    if (name.text.trim().isEmpty || numberphone.text.trim().isEmpty) {
      _showToast('Por favor, llene todos los campos', isError: true);
      return;
    }

    if (numberphone.text.length != 8 || !RegExp(r'^[0-9]{8}$').hasMatch(numberphone.text)) {
      _showToast('El número debe ser exactamente 8 dígitos numéricos', isError: true);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    var fiIDCliente = prefs.getString("fiIDCliente") ?? '0';

    var referido = {
      'fiIdequifaxClienteReferente': int.parse(fiIDCliente),
      'fcNombreReferido': name.text.trim(),
      'fcNumeroTelefono': numberphone.text, // No prefix added here
    };

    String jsonCreate = jsonEncode(referido);

    try {
      final response = await http.post(
        Uri.parse('${apiUrl}Usuario/ReferirCliente'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonCreate,
      );

      final decodedJson = jsonDecode(response.body);
      final codeStatus = decodedJson["code"];
      final messageStatus = decodedJson["message"];

      if (response.statusCode == 200 && codeStatus.toString() == '200') {
        _showToast(messageStatus, isSuccess: true);
        setState(() {
          name.clear();
          numberphone.clear();
        });
      } else {
        _showToast(messageStatus, isError: codeStatus.toString() != '409', isWarning: codeStatus.toString() == '409');
      }
    } catch (e) {
      _showToast('Error inesperado al enviar la solicitud', isError: true);
      debugPrint('Error: $e');
    }
  }

  void _showToast(String message, {bool isError = false, bool isWarning = false, bool isSuccess = false}) {
    CherryToast(
      themeColor: notifire.getbackcolor,
      backgroundColor: notifire.getbackcolor,
      title: Text(
        message,
        style: TextStyle(color: notifire.getdarkscolor),
        textAlign: TextAlign.start,
      ),
      borderRadius: 8,
      animationType: AnimationType.fromTop,
      toastDuration: const Duration(seconds: 3),
      icon: isSuccess
          ? Icons.check_circle
          : isWarning
              ? Icons.warning
              : Icons.error,
      iconColor: isSuccess
          ? Colors.green
          : isWarning
              ? Colors.orange
              : Colors.red,
    ).show(context);
  }
}