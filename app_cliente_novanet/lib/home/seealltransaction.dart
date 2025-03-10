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
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var piIDCliente = prefs.getString("fiIDCliente") ?? '0';
      var fiIDSolicitud = prefs.getString("fiIDCliente") ?? '0';

      final response = await http.get(Uri.parse(
          '${apiUrl}Servicio/PagosByCliente?piIDCliente=$piIDCliente&piIDSolicitud=$fiIDSolicitud'));

      if (response.statusCode == 200) {
        setState(() {
          listadodepagos = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        if (kDebugMode) print('Error en la solicitud: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (kDebugMode) print('Excepción en la solicitud: $e');
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> _getPaginatedItems() {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage) > listadodepagos.length
        ? listadodepagos.length
        : startIndex + _itemsPerPage;
    return listadodepagos.sublist(startIndex, endIndex);
  }

  int get _totalPages => (listadodepagos.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context);
    final paginatedItems = _getPaginatedItems();

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black26,
        backgroundColor: notifire.getprimerycolor,
        title: Text(
          CustomStrings.alltransaction,
          style: TextStyle(
            fontFamily: "Gilroy Bold",
            color: notifire.getdarkscolor,
            fontSize: height * 0.026,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: notifire.getdarkscolor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: width * 0.03),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _itemsPerPage,
                icon: Icon(Icons.arrow_drop_down, color: notifire.getdarkscolor),
                dropdownColor: notifire.getbackcolor,
                onChanged: (int? newValue) {
                  setState(() {
                    _itemsPerPage = newValue!;
                    _currentPage = 0;
                  });
                },
                items: [10, 25, 50].map<DropdownMenuItem<int>>((int value) => DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    'Mostrar $value',
                    style: TextStyle(
                      fontFamily: "Gilroy Medium",
                      color: notifire.getdarkscolor,
                      fontSize: height * 0.018,
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: notifire.getprimerycolor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading) 
              _buildLoadingState()
            else if (listadodepagos.isEmpty) 
              _buildEmptyState()
            else 
              _buildTransactionsList(paginatedItems),
            if (!_isLoading && listadodepagos.isNotEmpty) 
              _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() => SizedBox(
        height: height * 0.5,
        child: Center(
          child: CircularProgressIndicator(color: notifire.getorangeprimerycolor),
        ),
      );

  Widget _buildEmptyState() => SizedBox(
        height: height * 0.5,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/sin-dinero.png',
                height: height * 0.15,
                color: notifire.getorangeprimerycolor.withOpacity(0.8),
              ),
              SizedBox(height: height * 0.03),
              Text(
                'No Hay Transacciones',
                style: TextStyle(
                  fontFamily: "Gilroy Bold",
                  color: notifire.getdarkscolor,
                  fontSize: height * 0.024,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                'No tienes pagos realizados aún',
                style: TextStyle(
                  fontFamily: "Gilroy Medium",
                  color: notifire.getdarkscolor.withOpacity(0.6),
                  fontSize: height * 0.018,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildTransactionsList(List<dynamic> items) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Todas las Transacciones',
              style: TextStyle(
                fontFamily: "Gilroy Bold",
                color: notifire.getdarkscolor,
                fontSize: height * 0.024,
              ),
            ),
            SizedBox(height: height * 0.015),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => _buildTransactionCard(items[index]),
              ),
            ),
          ],
        ),
      );

  Widget _buildTransactionCard(dynamic item) => Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.008),
        child: Card(
          color: notifire.getbackcolor,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Row(
              children: [
                Container(
                  height: height * 0.06,
                  width: height * 0.06,
                  decoration: BoxDecoration(
                    color: notifire.getprimerycolor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Image.asset(
                      "images/logos.png",
                      height: height * 0.03
                    ),
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['fiIDTransaccion']} - ${item['fcOperacion']}',
                              style: TextStyle(
                                fontFamily: "Gilroy Bold",
                                color: notifire.getdarkscolor,
                                fontSize: height * 0.02,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'en',
                              symbol: item['fiIDMoneda'] == 1 ? 'L' : '\$',
                              decimalDigits: 2,
                            ).format(double.tryParse(item['fnValorAbonado']?.toString() ?? '0') ?? 0),
                            style: TextStyle(
                              fontFamily: "Gilroy Bold",
                              color: notifire.getorangeprimerycolor,
                              fontSize: height * 0.02,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.008),
                      Text(
                        item['fcLugarResidencia'] ?? 'Sin ubicación',
                        style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          color: notifire.getdarkscolor.withOpacity(0.7),
                          fontSize: height * 0.016,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height * 0.005),
                      Text(
                        DateFormat('dd/MM/yyyy').format(DateTime.parse(item['fdFechaTransaccion'])),
                        style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          color: notifire.getdarkscolor.withOpacity(0.7),
                          fontSize: height * 0.016,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildPaginationControls() => Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: _currentPage > 0 ? notifire.getorangeprimerycolor : Colors.grey,
                size: height * 0.025,
              ),
              onPressed: _currentPage > 0
                  ? () => setState(() => _currentPage--)
                  : null,
            ),
            Text(
              'Página ${_currentPage + 1} de $_totalPages',
              style: TextStyle(
                fontFamily: "Gilroy Medium",
                color: notifire.getdarkscolor,
                fontSize: height * 0.018,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: _currentPage < _totalPages - 1 ? notifire.getorangeprimerycolor : Colors.grey,
                size: height * 0.025,
              ),
              onPressed: _currentPage < _totalPages - 1
                  ? () => setState(() => _currentPage++)
                  : null,
            ),
          ],
        ),
      );
}