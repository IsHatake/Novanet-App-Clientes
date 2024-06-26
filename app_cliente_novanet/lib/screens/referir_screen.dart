import 'dart:convert';

import 'package:app_cliente_novanet/api.dart';
import 'package:app_cliente_novanet/utils/button.dart';
import 'package:app_cliente_novanet/utils/media.dart';
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
  TextEditingController name = TextEditingController();
  TextEditingController numberphone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Referir',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Gilroy Bold',
            color: notifire.getbackcolor,
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
              border: Border.all(color: notifire.getbackcolor),
            ),
            child: Icon(Icons.arrow_back, color: notifire.getbackcolor),
          ),
        ),
      ),
      body: Container(
        color: notifire.getprimerycolor,
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/referidos.png',
                  height: 300,
                  width: 300,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: name,
                    decoration: InputDecoration(
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xffd3d3d3)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Ingrese el Nombre del Referido',
                      hintStyle: TextStyle(
                        color: notifire.getdarkgreycolor,
                        fontSize: height / 60,
                      ),
                      fillColor: notifire.getbackcolor,
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: notifire.getorangeprimerycolor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: numberphone,
                    maxLength: 8,
                    decoration: InputDecoration(
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xffd3d3d3)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Ingrese el Número de Teléfono del Referido',
                      hintStyle: TextStyle(
                        color: notifire.getdarkgreycolor,
                        fontSize: height / 60,
                      ),
                      fillColor: notifire.getbackcolor,
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: notifire.getorangeprimerycolor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    validacion();
                  },
                  child: Custombutton.button(
                    notifire.getorangeprimerycolor,
                    'Confirmar',
                    width / 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  validacion() async {
    if (numberphone.text.isEmpty || name.text.isEmpty) {
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'Llene los Campos Vacio',
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    if (numberphone.text.length != 8) {
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'El Campo de Numero Requiere 8 digitos',
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    var fiIDCliente = prefs.getString("fiIDCliente") ?? '0';

    var referido = {
      'fiIdequifaxClienteReferente': int.parse(fiIDCliente),
      'fcNombreReferido': name.text,
      'fcNumeroTelefono': '504${numberphone.text}',
    };

    String jsonCreate = jsonEncode(referido);

    final response = await http.post(
      Uri.parse('${apiUrl}Usuario/ReferirCliente'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonCreate,
    );

    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);
      final codeStatus = decodedJson["code"];
      final messageStatus = decodedJson["message"];

      if (codeStatus.toString() == '200') {
        CherryToast.success(
          backgroundColor: notifire.getbackcolor,
          title: Text(
            '$messageStatus',
            style: TextStyle(color: notifire.getdarkscolor),
            textAlign: TextAlign.start,
          ),
          borderRadius: 5,
        ).show(context);
        setState(() {
          name.value = TextEditingValue.empty;
          numberphone.value = TextEditingValue.empty;

        });
        return;
      } else if (codeStatus.toString() == '409') {
        CherryToast.warning(
          backgroundColor: notifire.getbackcolor,
          title: Text('$messageStatus',
              style: TextStyle(color: notifire.getdarkscolor),
              textAlign: TextAlign.start),
          borderRadius: 5,
        ).show(context);
        return;
      } else {
        CherryToast.error(
          backgroundColor: notifire.getbackcolor,
          title: Text('$messageStatus',
              style: TextStyle(color: notifire.getdarkscolor),
              textAlign: TextAlign.start),
          borderRadius: 5,
        ).show(context);
      }
    } else {
      CherryToast.error(
        backgroundColor: notifire.getbackcolor,
        title: Text('Ha ocurrido un error Inesperado',
            style: TextStyle(color: notifire.getdarkscolor),
            textAlign: TextAlign.start),
        borderRadius: 5,
      ).show(context);
    }
  }
}
