import 'dart:convert';

import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PagosPage extends StatefulWidget {
  const PagosPage({
    Key? key,
  }) : super(key: key);

  @override
  _PagosPageState createState() => _PagosPageState();
}

class _PagosPageState extends State<PagosPage> {
  List<Map<String, dynamic>> listadodepagos = [];
  late List<Map<String, dynamic>> listadodepagosoriginal;
  String selectedMonth = '1';
  late ColorNotifire notifire;

  @override
  void initState() {
    super.initState();
    notifire = Provider.of<ColorNotifire>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String pagos = prefs.getString('datalogin[4]') ?? '[]';

    setState(() {
      listadodepagos = (jsonDecode(pagos)).cast<Map<String, dynamic>>();
      listadodepagosoriginal = List.from(listadodepagos);
      _applyFilter();
    });
  }

  void _applyFilter() {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime threeMonthsAgo =
        firstDayOfMonth.subtract(const Duration(days: 90));
    DateTime sixMonthsAgo = firstDayOfMonth.subtract(const Duration(days: 180));

    List<Map<String, dynamic>> filteredList = [];

    if (selectedMonth == '1') {
      filteredList = List.from(listadodepagosoriginal);
    } else if (selectedMonth == '2') {
      filteredList = listadodepagosoriginal.where((pago) {
        DateTime fechaTransaccion = DateTime.parse(pago['fdFechaTransaccion']);
        return fechaTransaccion.isAfter(threeMonthsAgo) ||
            fechaTransaccion.isAtSameMomentAs(firstDayOfMonth);
      }).toList();
    } else if (selectedMonth == '3') {
      filteredList = listadodepagosoriginal.where((pago) {
        DateTime fechaTransaccion = DateTime.parse(pago['fdFechaTransaccion']);
        return fechaTransaccion.isAfter(sixMonthsAgo) ||
            fechaTransaccion.isAtSameMomentAs(firstDayOfMonth);
      }).toList();
    }

    setState(() {
      listadodepagos = filteredList;
    });
  }

  void filtrarPagos(String? mes) {
    if (mes != null) {
      setState(() {
        selectedMonth = mes;
        _applyFilter();
      });
    }
  }

  String _getMonthName(int op) {
    switch (op) {
      case 1:
        return 'Todos los Pagos';
      case 2:
        return 'Últimos 3 Meses';
      case 3:
        return 'Últimos 6 Meses';
      default:
        return '';
    }
  }

  Widget _buildFilters(double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width / 18),
      child: Row(
        children: [
          Flexible(
            child: Text(
              selectedMonth == '1'
                  ? _getMonthName(int.parse(selectedMonth))
                  : 'Pagos de ${_getMonthName(int.parse(selectedMonth))}',
              style: TextStyle(
                fontFamily: "Gilroy Bold",
                color: notifire.getdarkscolor,
                fontSize: height / 40,
              ),
              overflow: TextOverflow.fade,
            ),
          ),
          const Spacer(),
          DropdownButton<String>(
            value: selectedMonth,
            dropdownColor: notifire.getbackcolor,
            onChanged: (String? newValue) {
              if (newValue != null) {
                filtrarPagos(newValue);
              }
            },
            items: <String>[for (int i = 1; i <= 3; i++) i.toString()]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  _getMonthName(int.parse(value)),
                  style: TextStyle(
                    fontSize: 14,
                    color: notifire.getdarkscolor,
                  ),
                  overflow: TextOverflow.fade,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildFilters(width, height),
        SizedBox(height: height / 50),
        Container(
          color: Colors.transparent,
          child: listadodepagos.isEmpty
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "images/sin-dinero.png",
                        color: notifire.getorangeprimerycolor,
                        height: height * 0.10,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Sin pagos realizados",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: notifire.getdarkscolor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listadodepagos.length,
                  itemBuilder: (context, index) {
                    var item = listadodepagos[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.05,
                        vertical: height * 0.01,
                      ),
                      child: Card(
                        color: notifire.getbackcolor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 2,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.02,
                              vertical: height * 0.005,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                            '${item['fiIDTransaccion'] ?? ''} - ${item['fcOperacion'] ?? ''}',
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
                                            item['fcLugarResidencia'] ?? '',
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
                                                item['fdFechaTransaccion'] ??
                                                    DateTime.now()
                                                        .toIso8601String(),
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
                                              double.tryParse(
                                                      item['fnValorAbonado']
                                                              ?.toString() ??
                                                          '0') ??
                                                  0,
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
