// ignore_for_file: non_constant_identifier_names, camel_case_types, unused_local_variable

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
  const usuarios_Screen({Key? key, required this.fbprincipal})
      : super(key: key);

  @override
  State<usuarios_Screen> createState() => _usuarios_ScreenState();
}

class _usuarios_ScreenState extends State<usuarios_Screen> {
  late ColorNotifire notifire;
  int _itemsPerPage = 10;
  int _currentPage = 0;
  List listadodeusuarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var piIDCliente = prefs.getString("fiIDCliente") ?? '0';

      final response = await http.get(Uri.parse(
          '${apiUrl}Usuario/Usuarios_Listado_ByCliente?piIDCuentaFamiliar=$piIDCliente'));

      if (response.statusCode == 200) {
        setState(() {
          listadodeusuarios = jsonDecode(response.body);
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

  Future<void> _deleteUsuario(int id) async {
    try {
      final response = await http.post(Uri.parse('${apiUrl}Usuario/Usuarios_Delete?piIDUnico=$id'));
      final decodedJson = jsonDecode(response.body);
      final codeStatus = decodedJson["code"];
      final messageStatus = decodedJson["message"];

      if (response.statusCode == 200 && codeStatus.toString() == '200') {
        CherryToast.success(
          backgroundColor: notifire.getbackcolor,
          title: Text(messageStatus, style: TextStyle(color: notifire.getdarkscolor)),
          borderRadius: 5,
        ).show(context);
        await _loadUsuarios(); // Refresh the list
      } else {
        CherryToast.warning(
          backgroundColor: notifire.getbackcolor,
          title: Text(messageStatus, style: TextStyle(color: notifire.getdarkscolor)),
          borderRadius: 5,
        ).show(context);
      }
    } catch (e) {
      if (kDebugMode) print('Excepción en la solicitud: $e');
      CherryToast.error(
        backgroundColor: notifire.getbackcolor,
        title: Text('Error al eliminar usuario', style: TextStyle(color: notifire.getdarkscolor)),
      ).show(context);
    }
  }

  List<dynamic> _getPaginatedItems() {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage) > listadodeusuarios.length
        ? listadodeusuarios.length
        : startIndex + _itemsPerPage;
    return listadodeusuarios.sublist(startIndex, endIndex);
  }

  int get _totalPages => (listadodeusuarios.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context);
    final paginatedItems = _getPaginatedItems();

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black26,
        centerTitle: true,
        backgroundColor: notifire.getprimerycolor,
        title: Text(
          'Usuarios',
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
            else if (listadodeusuarios.isEmpty)
              _buildEmptyState()
            else
              _buildUsuariosList(paginatedItems),
            if (!_isLoading && listadodeusuarios.isNotEmpty)
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
                'images/familia.png',
                height: height * 0.15,
                color: notifire.getdarkscolor.withOpacity(0.7),
              ),
              SizedBox(height: height * 0.03),
              Text(
                'No Hay Usuarios',
                style: TextStyle(
                  fontFamily: "Gilroy Bold",
                  color: notifire.getdarkscolor,
                  fontSize: height * 0.024,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                'Agrega usuarios para verlos aquí',
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

  Widget _buildUsuariosList(List<dynamic> items) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mis Usuarios',
                  style: TextStyle(
                    fontFamily: "Gilroy Bold",
                    color: notifire.getdarkscolor,
                    fontSize: height * 0.024,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    int fiIDEquifax = int.parse(prefs.getString("fiIDCuentaFamiliar") ?? '0');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdduserFamily(
                          fiIDEquifax: fiIDEquifax,
                          redireccion: false,
                          fbprincipal: widget.fbprincipal,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.person_add_alt, color: Colors.white, size: height * 0.025),
                  label: Text(
                    'Agregar',
                    style: TextStyle(
                      fontFamily: "Gilroy Bold",
                      color: Colors.white,
                      fontSize: height * 0.018,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: notifire.getorangeprimerycolor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.015),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.015),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => _buildUsuarioCard(items[index]),
              ),
            ),
          ],
        ),
      );

  Widget _buildUsuarioCard(dynamic item) => Padding(
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
                    child: Image.network(
                      item['NombreArchivo'].toString(),
                      height: height * 0.03,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        color: notifire.getdarkscolor,
                        size: height * 0.03,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['fcNombreUsuario'].toString(),
                        style: TextStyle(
                          fontFamily: "Gilroy Bold",
                          color: notifire.getdarkscolor,
                          fontSize: height * 0.02,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height * 0.008),
                      Text(
                        item['fiTipodeUsuario'] == 1 ? 'Usuario Principal' : 'Usuario Familiar',
                        style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          color: item['fiTipodeUsuario'] == 1 ? Colors.green : Colors.orange,
                          fontSize: height * 0.016,
                        ),
                      ),
                      SizedBox(height: height * 0.005),
                      Text(
                        item['fcUsuarioAcceso'].toString(),
                        style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          color: notifire.getdarkscolor.withOpacity(0.7),
                          fontSize: height * 0.016,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (item['fiTipodeUsuario'] != 1)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: height * 0.03),
                    onPressed: () => _showDeleteDialog(
                      item['fcNombreUsuario'].toString(),
                      item['fcUsuarioAcceso'].toString(),
                      item['fiIDUnico'],
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
              onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
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
              onPressed: _currentPage < _totalPages - 1 ? () => setState(() => _currentPage++) : null,
            ),
          ],
        ),
      );

  Future<void> _showDeleteDialog(String usuario, String correo, int id) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: notifire.getbackcolor,
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: height * 0.03),
              SizedBox(width: width * 0.03),
              Text(
                'Eliminar Usuario',
                style: TextStyle(
                  fontFamily: 'Gilroy Bold',
                  color: notifire.getdarkscolor,
                  fontSize: height * 0.024,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de eliminar al usuario "$usuario"?',
                style: TextStyle(
                  fontFamily: 'Gilroy Medium',
                  color: notifire.getdarkscolor,
                  fontSize: height * 0.018,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                'Correo: $correo',
                style: TextStyle(
                  fontFamily: 'Gilroy Medium',
                  color: notifire.getdarkscolor.withOpacity(0.7),
                  fontSize: height * 0.016,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: 'Gilroy Bold',
                  color: Colors.red,
                  fontSize: height * 0.018,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteUsuario(id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: notifire.getorangeprimerycolor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.015),
              ),
              child: Text(
                'Eliminar',
                style: TextStyle(
                  fontFamily: 'Gilroy Bold',
                  color: Colors.white,
                  fontSize: height * 0.018,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}