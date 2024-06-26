// ignore_for_file: non_constant_identifier_names

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
import '../utils/string.dart';

class Seealltransaction extends StatefulWidget {
  const Seealltransaction({Key? key}) : super(key: key);

  @override
  State<Seealltransaction> createState() => _SeealltransactionState();
}

class _SeealltransactionState extends State<Seealltransaction> {
  late ColorNotifire notifire;
  int _startIndex = 0;
  int _endIndex = 0;
  int _itemsPerPage = 10;
  List listadodepagos = [];

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
      var fiIDSolicitud = prefs.getString("piIDSolicitud");

      final response = await http.get(Uri.parse(
          '${apiUrl}Servicio/PagosByCliente?piIDCliente=$piIDCliente&piIDSolicitud=$fiIDSolicitud'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          listadodepagos = data;
          _endIndex = (_itemsPerPage < listadodepagos.length)
              ? _itemsPerPage - 1
              : listadodepagos.length - 1;
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
          CustomStrings.alltransaction,
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
                    style:  TextStyle(color: notifire.getdarkscolor),
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
            if (listadodepagos.isEmpty)
              const CircularProgressIndicator()
            else
              Container(
                height: height / 1.15,
                color: Colors.transparent,
                child: Card(
                  color: notifire.getbackcolor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
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
                          if (i < listadodepagos.length)
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
                                          listadodepagos[i]['fiIDTransaccion']
                                                  .toString() +
                                              ' - ' +
                                              listadodepagos[i]['fcOperacion'],
                                          style: TextStyle(
                                            fontFamily: "Gilroy Bold",
                                            color: notifire.getdarkscolor,
                                            fontSize: height * 0.015,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: height * 0.005),
                                        Text(
                                          DateFormat('dd/MM/yyyy').format(
                                            DateTime.parse(
                                              listadodepagos[i]
                                                  ['fdFechaTransaccion'],
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontFamily: "Gilroy Medium",
                                            color: notifire.getdarkscolor
                                                .withOpacity(0.6),
                                            fontSize: height * 0.013,
                                          ),
                                        ),
                                        SizedBox(height: height * 0.005),
                                        Text(
                                          NumberFormat.currency(
                                            locale: 'es',
                                            symbol: '\$',
                                          ).format(
                                            double.parse(
                                              listadodepagos[i]
                                                      ['fnValorAbonado']
                                                  .toString(),
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontFamily: "Gilroy Bold",
                                            color: notifire.getdarkscolor,
                                            fontSize: height * 0.02,
                                          ),
                                        ),
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
                              "Mostrando ${_startIndex + 1} - ${(_endIndex < listadodepagos.length) ? _endIndex + 1 : listadodepagos.length} de ${listadodepagos.length} registros",
                              style: TextStyle(
                                fontFamily: "Gilroy Medium",
                                color: notifire.getdarkscolor.withOpacity(0.6),
                                fontSize: height * 0.013,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: (_endIndex < listadodepagos.length - 1)
                                  ? () {
                                      setState(() {
                                        _startIndex += _itemsPerPage;
                                        _endIndex = (_endIndex + _itemsPerPage <
                                                listadodepagos.length - 1)
                                            ? _endIndex + _itemsPerPage
                                            : listadodepagos.length - 1;
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
