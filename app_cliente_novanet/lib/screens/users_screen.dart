// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:convert';

import 'package:app_cliente_novanet/screens/adduserFamily.dart';
import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../api.dart';
import '../utils/colornotifire.dart';
import '../utils/media.dart';

class usuarios_Screen extends StatefulWidget {
  final bool fbprincipal;
  const usuarios_Screen({Key? key, required this.fbprincipal}) : super(key: key);

  @override
  State<usuarios_Screen> createState() => _usuarios_ScreenState();
}

class _usuarios_ScreenState extends State<usuarios_Screen> {
  late ColorNotifire notifire;
  int _startIndex = 0;
  int _endIndex = 0;
  int _itemsPerPage = 10;
  List listadodeusuarios = [];

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  @override
  void initState() {
    UsuariosByCliente();
    super.initState();
  }

  Future<void> UsuariosByCliente() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      var piIDCliente = prefs.getString("fiIDCliente");

      final response = await http.get(Uri.parse(
          '${apiUrl}Usuario/Usuarios_Listado_ByCliente?piIDCuentaFamiliar=$piIDCliente'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          listadodeusuarios = data;
          _endIndex = (_itemsPerPage < listadodeusuarios.length)
              ? _itemsPerPage - 1
              : listadodeusuarios.length - 1;
        });
      } else {
        if (kDebugMode) {
          print('Error en la solicitud: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Excepción en la solicitud: $e');
      }
    }
  }

  Future<void> Usuarios_Delete(id) async {
    try {
      final response = await http
          .post(Uri.parse('${apiUrl}Usuario/Usuarios_Delete?piIDUnico=$id'));

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
      }
    } catch (e) {
      if (kDebugMode) {
        print('Excepción en la solicitud: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: notifire.getwhite),
        backgroundColor: notifire.getorangeprimerycolor,
        title: Text(
          'Usuarios',
          style: TextStyle(
              fontFamily: "Gilroy Bold",
              color: notifire.getwhite,
              fontSize: 20),
        ),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<int>(
              value: _itemsPerPage,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: notifire.getdarkscolor),
              underline: Container(
                height: 2,
                color: notifire.getdarkscolor,
              ),
              dropdownColor: notifire.getbackcolor,
              onChanged: (int? newValue) {
                setState(() {
                  _itemsPerPage = newValue!;
                  UsuariosByCliente();
                });
              },
              items: <int>[10, 25, 50].map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    'Mostrar ' + value.toString(),
                    style: TextStyle(color: notifire.getdarkscolor),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          IconButton(
            icon: Icon(Icons.person_add_alt, color: notifire.getwhite),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              int fiIDEquifax = int.parse(prefs.getString("fiIDCuentaFamiliar") ?? '0');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdduserFamily(fiIDEquifax: fiIDEquifax, redireccion: false, fbprincipal:widget.fbprincipal),
                ),
              );
            },
          ),
          const SizedBox(
            width: 5,
          ),
        ],
      ),
      backgroundColor: notifire.getprimerycolor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height / 50,
            ),
            if (listadodeusuarios.isEmpty)
              Center(
                child: CircularProgressIndicator(
                  color: notifire.getorangeprimerycolor,
                ),
              )
            else
              Container(
                color: notifire.getprimerycolor,
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/familia.png',
                          height: 200,
                          width: 200,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            Container(
              height: height / 1.15,
              color: Colors.transparent,
              child: Card(
                color: notifire.getbackcolor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black12, width: 4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: height * 0.01,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = _startIndex; i <= _endIndex; i++)
                        if (i < listadodeusuarios.length)
                          Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: height * 0.07,
                                    width: width / 7,
                                    decoration: BoxDecoration(
                                      color: notifire.getprimerycolor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Image.network(
                                        listadodeusuarios[i]['NombreArchivo']
                                            .toString(),
                                        height: height / 30,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          listadodeusuarios[i]
                                                  ['fcNombreUsuario']
                                              .toString(),
                                          style: TextStyle(
                                            fontFamily: "Gilroy Bold",
                                            color: notifire.getdarkscolor,
                                            fontSize: height * 0.015,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                        SizedBox(height: height * 0.005),
                                        Text(
                                          listadodeusuarios[i]
                                                      ['fiTipodeUsuario'] ==
                                                  1
                                              ? 'Usuario Principal'
                                              : 'Usuario Secundario',
                                          style: TextStyle(
                                            fontFamily: "Gilroy Medium",
                                            color: listadodeusuarios[i]
                                                        ['fiTipodeUsuario'] ==
                                                    1
                                                ? Colors.green.shade200
                                                : Colors.orange.shade200,
                                            fontSize: height * 0.015,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                        SizedBox(height: height * 0.005),
                                        Text(
                                          listadodeusuarios[i]
                                                  ['fcUsuarioAcceso']
                                              .toString(),
                                          style: TextStyle(
                                            fontFamily: "Gilroy Medium",
                                            color: notifire.getdarkscolor
                                                .withOpacity(0.6),
                                            fontSize: height * 0.013,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                        SizedBox(height: height * 0.005),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  if (listadodeusuarios[i]['fiTipodeUsuario'] !=
                                      1)
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.white),
                                      label: const Text("Eliminar"),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        _showMyDialog(
                                            listadodeusuarios[i]
                                                    ['fcNombreUsuario']
                                                .toString(),
                                            listadodeusuarios[i]
                                                    ['fcUsuarioAcceso']
                                                .toString(),
                                            listadodeusuarios[i]['fiIDUnico']);
                                      },
                                    ),
                                ],
                              ),
                              SizedBox(height: height * 0.005),
                              const Divider(),
                            ],
                          ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: (_startIndex > 0)
                                ? () {
                                    setState(() {
                                      _startIndex -= _itemsPerPage;
                                      _endIndex -= _itemsPerPage;
                                    });
                                  }
                                : null,
                            child: const Text('<'),
                          ),
                          Text(
                            "Mostrando ${_startIndex + 1} - ${(_endIndex < listadodeusuarios.length) ? _endIndex + 1 : listadodeusuarios.length} de ${listadodeusuarios.length} registros",
                            style: TextStyle(
                              fontFamily: "Gilroy Medium",
                              color: notifire.getdarkscolor.withOpacity(0.6),
                              fontSize: height * 0.013,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: (_endIndex <
                                    listadodeusuarios.length - 1)
                                ? () {
                                    setState(() {
                                      _startIndex += _itemsPerPage;
                                      _endIndex = (_endIndex + _itemsPerPage <
                                              listadodeusuarios.length - 1)
                                          ? _endIndex + _itemsPerPage
                                          : listadodeusuarios.length - 1;
                                    });
                                  }
                                : null,
                            child: const Text('>'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog(String Usuario, String Correo, int id) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(32.0),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: notifire.getprimerycolor,
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            height: height / 3,
            child: Column(
              children: [
                SizedBox(
                  height: height / 40,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      const Spacer(),
                      Icon(
                        Icons.clear,
                        color: notifire.getdarkscolor,
                      ),
                      SizedBox(
                        width: width / 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height / 40,
                ),
                Text(
                  'Desea eliminar al Usuario de $Usuario',
                  style: TextStyle(
                    color: notifire.getdarkscolor,
                    fontFamily: 'Gilroy Bold',
                    fontSize: height / 50,
                  ),
                ),
                Text(
                  'con correo $Correo',
                  style: TextStyle(
                    color: notifire.getdarkscolor,
                    fontFamily: 'Gilroy Bold',
                    fontSize: height / 50,
                  ),
                ),
                SizedBox(
                  height: height / 20,
                ),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await Future.delayed(const Duration(seconds: 1));

                    await Usuarios_Delete(id);
                    await UsuariosByCliente();
                  },
                  child: Container(
                    height: height / 18,
                    width: width / 2.5,
                    decoration: BoxDecoration(
                      color: notifire.getorangeprimerycolor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Eliminar',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Gilroy Bold',
                            fontSize: height / 55),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height / 100,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: height / 18,
                    width: width / 2.5,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                            color: const Color(0xffEB5757),
                            fontFamily: 'Gilroy Bold',
                            fontSize: height / 55),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
