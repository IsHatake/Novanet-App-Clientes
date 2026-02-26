// ignore_for_file: camel_case_types, non_constant_identifier_names, unused_local_variable

import 'dart:convert';
import 'package:app_cliente_novanet/screens/referir_screen.dart';
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
  int _itemsPerPage = 10;
  List listadodereferidos = [];
  bool _isLoading = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadReferidos();
  }

  Future<void> _loadReferidos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var piIDCliente = prefs.getString("fiIDCliente") ?? '0';

      final response = await http.post(Uri.parse(
          '${apiUrl}Servicio/ClientesReferidos_Listado_ByCliente?piIDEquifaxClienteReferente=$piIDCliente'));

      if (response.statusCode == 200) {
        setState(() {
          listadodereferidos = jsonDecode(response.body);
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
    final endIndex = (startIndex + _itemsPerPage) > listadodereferidos.length
        ? listadodereferidos.length
        : startIndex + _itemsPerPage;
    return listadodereferidos.sublist(startIndex, endIndex);
  }

  int get _totalPages => (listadodereferidos.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context);
    final paginatedItems = _getPaginatedItems();

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black26,
        centerTitle: true,
        backgroundColor: notifire.getorangeprimerycolor,
        title: Text(
          'Referidos',
          style: TextStyle(
            fontFamily: "Gilroy Bold",
            color: notifire.getwhite,
            fontSize: height * 0.025,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: notifire.getwhite),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: width * 0.03),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _itemsPerPage,
                icon: Icon(Icons.arrow_drop_down, color: notifire.getwhite),
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
          IconButton(
            icon: Icon(Icons.person_add_alt, color: notifire.getwhite, size: height * 0.03),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferirScreen())),
          ),
        ],
      ),
      backgroundColor: notifire.getprimerycolor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.02),
        child: Column(
          children: [
            if (_isLoading) 
              _buildLoadingState()
            else if (listadodereferidos.isEmpty) 
              _buildEmptyState()
            else 
              _buildReferidosList(paginatedItems),
            if (!_isLoading && listadodereferidos.isNotEmpty) 
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
                'images/referidos.png',
                height: height * 0.2,
                width: height * 0.2,
                color: notifire.getorangeprimerycolor.withOpacity(0.8),
              ),
              SizedBox(height: height * 0.03),
              Text(
                'No Tienes Referidos',
                style: TextStyle(
                  fontFamily: "Gilroy Bold",
                  color: notifire.getdarkscolor,
                  fontSize: height * 0.024,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                'Invita a amigos para verlos aquí',
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

  Widget _buildReferidosList(List<dynamic> items) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'images/referidos.png',
                height: height * 0.15,
                width: height * 0.15,
              ),
            ),
            SizedBox(height: height * 0.02),
            Text(
              'Mis Referidos',
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
                itemBuilder: (context, index) => _buildReferidoCard(items[index]),
              ),
            ),
          ],
        ),
      );

  Widget _buildReferidoCard(dynamic item) => Padding(
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
                      Text(
                        item['fcNombreReferido'].toString(),
                        style: TextStyle(
                          fontFamily: "Gilroy Bold",
                          color: notifire.getdarkscolor,
                          fontSize: height * 0.02,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height * 0.008),
                      Text(
                        item['fbClienteInstalado'] == true ? 'Activo' : 'No Activo',
                        style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          color: item['fbClienteInstalado'] == true ? Colors.green : Colors.red,
                          fontSize: height * 0.016,
                        ),
                      ),
                      SizedBox(height: height * 0.005),
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(DateTime.parse(item['fdFechaCreacion']))} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(item['fdFechaVencimiento']))}',
                        style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          color: notifire.getdarkscolor.withOpacity(0.6),
                          fontSize: height * 0.014,
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