// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../api.dart';
import '../utils/colornotifire.dart';
import '../utils/media.dart';

class referidos_Screen extends StatefulWidget {
  const referidos_Screen({Key? key}) : super(key: key);

  @override
  State<referidos_Screen> createState() => _referidos_ScreenState();
}

class _referidos_ScreenState extends State<referidos_Screen> {
  late ColorNotifire notifire;
  int _startIndex = 0;
  int _endIndex = 0;
  int _itemsPerPage = 10;
  List listadodereferidos = [];

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
    PagosByCliente();
    super.initState();
  }

  Future<void> PagosByCliente() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      var piIDCliente = prefs.getString("fiIDCliente");

      final response = await http.post(Uri.parse(
          '${apiUrl}Servicio/ClientesReferidos_Listado_ByCliente?piIDEquifaxClienteReferente=$piIDCliente'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          listadodereferidos = data;
          _endIndex = (_itemsPerPage < listadodereferidos.length)
              ? _itemsPerPage - 1
              : listadodereferidos.length - 1;
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

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: notifire.getdarkscolor),
        backgroundColor: notifire.getprimerycolor,
        title: Text(
          'Referidos',
          style: TextStyle(
              fontFamily: "Gilroy Bold",
              color: notifire.getdarkscolor,
              fontSize: height / 40),
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
                  PagosByCliente();
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
        ],
      ),
      backgroundColor: notifire.getprimerycolor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height / 50,
            ),
            if (listadodereferidos.isEmpty)
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
                          'images/referidos.png',
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
                        if (i < listadodereferidos.length)
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
                                      child: Image.asset(
                                        "images/logos.png",
                                        height: height / 30,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        listadodereferidos[i]
                                                    ['fcNombreReferido']
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
                                        listadodereferidos[i]
                                                    ['fbClienteInstalado'] ==
                                                true
                                            ? 'Activo'
                                            : 'No Activo',
                                        style: TextStyle(
                                          fontFamily: "Gilroy Medium",
                                          color: listadodereferidos[i]
                                                      ['fbClienteInstalado'] ==
                                                  true
                                              ? Colors.green.shade200
                                              : Colors.red.shade200,
                                          fontSize: height * 0.015,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                      ),
                                      SizedBox(height: height * 0.005),
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(
                                              DateTime.parse(
                                                listadodereferidos[i]
                                                    ['fdFechaCreacion'],
                                              ),
                                            ) +
                                            ' - ' +
                                            DateFormat('dd/MM/yyyy').format(
                                              DateTime.parse(
                                                listadodereferidos[i]
                                                    ['fdFechaVencimiento'],
                                              ),
                                            ),
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
                            "Mostrando ${_startIndex + 1} - ${(_endIndex < listadodereferidos.length) ? _endIndex + 1 : listadodereferidos.length} de ${listadodereferidos.length} registros",
                            style: TextStyle(
                              fontFamily: "Gilroy Medium",
                              color: notifire.getdarkscolor.withOpacity(0.6),
                              fontSize: height * 0.013,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: (_endIndex <
                                    listadodereferidos.length - 1)
                                ? () {
                                    setState(() {
                                      _startIndex += _itemsPerPage;
                                      _endIndex = (_endIndex + _itemsPerPage <
                                              listadodereferidos.length - 1)
                                          ? _endIndex + _itemsPerPage
                                          : listadodereferidos.length - 1;
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
}
