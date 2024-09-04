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
  int _itemsPerPage = 10;
  List listadodepagos = [];
  bool _isLoading = true;

  int _currentPage = 0; // Página actual

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
      var fiIDSolicitud = prefs.getString("fiIDCliente");

      final response = await http.get(Uri.parse(
          '${apiUrl}Servicio/PagosByCliente?piIDCliente=$piIDCliente&piIDSolicitud=$fiIDSolicitud'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          listadodepagos = data;
          _isLoading = false;
        });
      } else {
        if (kDebugMode) {
          print('Error en la solicitud: ${response.statusCode}');
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Excepción en la solicitud: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    // Calcular los índices de inicio y fin para la página actual
    final int _startIndex = _currentPage * _itemsPerPage;
    final int _endIndex = (_startIndex + _itemsPerPage) > listadodepagos.length
        ? listadodepagos.length
        : _startIndex + _itemsPerPage;

    // Elementos para la página actual
    List<dynamic> currentPageItems = [];
    if (_startIndex < listadodepagos.length) {
      currentPageItems = listadodepagos.sublist(
        _startIndex,
        _endIndex,
      );
    }

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
              border: Border.all(color: notifire.getdarkscolor),
            ),
            child: Icon(Icons.arrow_back, color: notifire.getdarkscolor),
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
                  _currentPage = 0; // Reiniciar a la primera página
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: notifire.getorangeprimerycolor,
              ),
            )
          : listadodepagos.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'images/sin-dinero.png',
                        color: notifire.getorangeprimerycolor,
                        height: MediaQuery.of(context).size.height * 0.15,
                        width: 200,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No cuentas con Pagos hechos aquí',
                        style: TextStyle(
                          fontFamily: "Gilroy Bold",
                          color: notifire.getdarkscolor,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(40, 40),
                            backgroundColor: (_currentPage > 0)
                                ? notifire.getorangeprimerycolor
                                : Colors.grey,
                          ),
                          onPressed: () {
                            if (_currentPage > 0) {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        Text(
                          "Mostrando ${_startIndex + 1} - $_endIndex de ${listadodepagos.length} registros",
                          style: TextStyle(
                            fontFamily: "Gilroy Medium",
                            color: notifire.getdarkscolor.withOpacity(0.6),
                            fontSize: height * 0.013,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(40, 40),
                            backgroundColor: (_endIndex < listadodepagos.length)
                                ? notifire.getorangeprimerycolor
                                : Colors.grey,
                          ),
                          onPressed: (_endIndex < listadodepagos.length)
                              ? () {
                                  setState(() {
                                    _currentPage++; // Avanzar una página
                                  });
                                }
                              : null,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: currentPageItems.length,
                        itemBuilder: (context, i) {
                          return Column(
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currentPageItems[i]['fiIDTransaccion']
                                                  .toString() +
                                              ' - ' +
                                              currentPageItems[i]
                                                  ['fcOperacion'],
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
                                          currentPageItems[i]
                                              ['fcLugarResidencia'],
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
                                        Text(
                                          DateFormat('dd/MM/yyyy').format(
                                            DateTime.parse(
                                              currentPageItems[i]
                                                  ['fdFechaTransaccion'],
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
                                        Text(
                                          NumberFormat.currency(
                                            locale: 'es',
                                            symbol: '\$',
                                          ).format(
                                            double.parse(
                                              currentPageItems[i]
                                                      ['fnValorAbonado']
                                                  .toString(),
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontFamily: "Gilroy Bold",
                                            color: notifire.getdarkscolor,
                                            fontSize: height * 0.02,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.005),
                              const Divider(),
                            ],
                          );
                        },
                      ),
                    ),
                
                  ],
                ),
    );
  }
}
