// ignore_for_file: camel_case_types, non_constant_identifier_names, unnecessary_null_comparison, empty_catches

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:app_cliente_novanet/utils/media.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import '../api.dart';
import '../utils/colornotifire.dart';

class AddServices_Screen extends StatefulWidget {
  final String title;
  const AddServices_Screen(this.title, {Key? key}) : super(key: key);

  @override
  State<AddServices_Screen> createState() => _AddServices_ScreenState();
}

class _AddServices_ScreenState extends State<AddServices_Screen> {
  late ColorNotifire notifire;

  List productosPropios = [];
  late final _productosPropiosoriginalDetalles = List.from(productosPropios);

  List detallessinadquirir = [];

  late final _originaldetallesnoadd = List.from(detallessinadquirir);

  List solicitudes = [];
  List productosSolicitar = [];

  List solicitudesHechas = [];

  @override
  void initState() {
    Productos_ListaPorCliente();
    ProductosAsolicitud_ListaPorCliente();
    Solicitudes_AdicionProducto_Listado();
    super.initState();
  }

  Future<void> Productos_ListaPorCliente() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var fiIDSolicitud = prefs.getString("piIDSolicitud");

      final response = await http.get(Uri.parse(
          '${apiUrl}Servicio/Productos_ListaPorCliente?piIDSolicitud=$fiIDSolicitud'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          productosPropios = data;
        });
      } else {
        if (kDebugMode) {
          print('Error en la solicitud: ${response.statusCode}');
        }
        setState(() {
          productosPropios = [];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Excepción en la solicitud: $e');
      }
      setState(() {
        productosPropios = [];
      });
    }
  }

  Future<void> ProductosAsolicitud_ListaPorCliente() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var fiIDSolicitud = prefs.getString("piIDSolicitud");

      final response = await http.get(Uri.parse(
          '${apiUrl}Servicio/ProductosAsolicitud_ListaPorCliente?piIDSolicitud=$fiIDSolicitud'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          detallessinadquirir = data;
        });
      } else {
        if (kDebugMode) {
          print('Error en la solicitud: ${response.statusCode}');
        }
        setState(() {
          detallessinadquirir = [];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Excepción en la solicitud: $e');
      }
      setState(() {
        productosPropios = [];
      });
    }
  }

  Future<List<dynamic>> Solicitudes_AdicionProducto_Listado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var piIDSolicitud = prefs.getString("piIDSolicitud");

      final response = await http.get(
        Uri.parse(
            '${apiUrl}Servicio/Solicitudes_AdicionProducto_Listado?piIDSolicitud=$piIDSolicitud'),
      );

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body) as List;
        setState(() {
          solicitudesHechas = decodedJson;
        });
        return decodedJson;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Excepción en la solicitud: $e');
      }
      return [];
    }
  }

  Future<void> Solicitudes_AdicionProducto_ListadoDetalles(
      int piIDAdicionProduto) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${apiUrl}Servicio/Solicitudes_AdicionProducto_Detalles?piIDAdicionProduto=$piIDAdicionProduto'),
      );

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body) as List;
        _showDetalles(decodedJson);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {}
  }

  SendSolicitudNueva() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var piIDSolicitud = prefs.getString("piIDSolicitud");
      if (piIDSolicitud == null) {
        throw Exception('piIDSolicitud is null or invalid');
      }
      List<Map<String, dynamic>> jsonDetalles = [];
      for (var detalle in productosSolicitar) {
        var detalleMap = {
          'fiIDAdicionProduto': detalle['fiIDAdicionProduto'],
          'fiIDProducto': detalle['fiIDProducto'],
          'fiCantidad': detalle['Cantidad'] ?? 1,
        };
        jsonDetalles.add(detalleMap);
      }

      var createAdicionProduto = {
        'fiIDSolicitud': int.parse(piIDSolicitud),
        'jsondetalles': jsonDetalles,
      };

      String jsonCreate = jsonEncode(createAdicionProduto);

      final response = await http.post(
        Uri.parse('${apiUrl}Servicio/SolicitudesAdicionProducto_Insertar'),
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
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.pop(context);
            setState(() {});
            solicitudes = [];
            productosSolicitar = [];
          });
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
        throw Exception('Failed to load data');
      }
    } catch (e) {
      return [];
    }
  }

  TabController? controller;

  final TextEditingController _misproductosController = TextEditingController();
  final TextEditingController _noadquiridosController = TextEditingController();

  void addSolicitudes(int id, String fiIDProducto) {
    var detalle =
        _originaldetallesnoadd.firstWhere((detalle) => detalle['RowNum'] == id);

    var nuevoProducto = {
      'fiIDAdicionProduto': detalle['RowNum'],
      'fiIDProducto': detalle['fiIDProducto'],
      'fiCantidad': 1
    };

    productosSolicitar.add(nuevoProducto);
    solicitudes.add(detalle);
    _originaldetallesnoadd.remove(detalle);
  }

  void lessSolicitudes(int id) {
    var detalle = productosSolicitar
        .firstWhere((detalle) => detalle['fiIDAdicionProduto'] == id);
    var detalle2 = solicitudes.firstWhere((detalle) => detalle['RowNum'] == id);

    productosSolicitar.remove(detalle);
    solicitudes.remove((detalle2));
  }

  bool visble_form = false;
  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Gilroy Bold',
            color: notifire.getwhite,
            fontWeight: FontWeight.w400,
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
              border: Border.all(color: notifire.getwhite),
            ),
            child: Icon(Icons.arrow_back, color: notifire.getwhite),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _showDialogSolicitudes();
            },
            child: Icon(
              Icons.assignment,
              color: notifire.getwhite,
              size: MediaQuery.of(context).size.height * 0.05,
            ),
          ),
          const SizedBox(width: 15)
        ],
      ),
      backgroundColor: notifire.getprimerycolor,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Productos Adquiridos',
                  style: TextStyle(
                    color: notifire.getdarkscolor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _misproductosController,
                onChanged: _filterProductsAdquiridos,
                autofocus: false,
                style: TextStyle(
                  fontSize: 12,
                  color: notifire.getdarkscolor,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: notifire.getbackcolor,
                  hintText: 'Buscar en tus productos',
                  hintStyle:
                      TextStyle(color: notifire.getdarkgreycolor, fontSize: 12),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: notifire.getorangeprimerycolor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xffd3d3d3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: <DataColumn>[
                      DataColumn(
                        label: Text(
                          '#',
                          style: TextStyle(
                              fontSize: 15, color: notifire.getdarkscolor),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          ' ',
                          style: TextStyle(
                              fontSize: 15, color: notifire.getdarkscolor),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Articulo',
                          style: TextStyle(
                              fontSize: 15, color: notifire.getdarkscolor),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Marca',
                          style: TextStyle(
                              fontSize: 15, color: notifire.getdarkscolor),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Tipo Producto',
                          style: TextStyle(
                              fontSize: 15, color: notifire.getdarkscolor),
                        ),
                      ),
                    ],
                    rows: _buildDataRows(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                reverseDuration: const Duration(milliseconds: 200),
                switchInCurve: Curves.decelerate,
                switchOutCurve: Curves.decelerate,
                child: visble_form
                    ? Column(
                        children: [
                          Center(
                            child: Text(
                              'Productos sin Adquirir',
                              style: TextStyle(
                                color: notifire.getdarkscolor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            key: const ValueKey('textField'),
                            controller: _noadquiridosController,
                            onChanged: _filterProducts,
                            autofocus: false,
                            style: TextStyle(
                              fontSize: 12,
                              color: notifire.getdarkscolor,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: notifire.getbackcolor,
                              hintText: 'Buscar en Productos no Adquiridos',
                              hintStyle: TextStyle(
                                  color: notifire.getdarkgreycolor,
                                  fontSize: 12),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: notifire.getorangeprimerycolor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xffd3d3d3)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: _buildCard(),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            reverseDuration: const Duration(milliseconds: 200),
            switchInCurve: Curves.decelerate,
            switchOutCurve: Curves.decelerate,
            child: visble_form
                ? FloatingActionButton(
                    key: UniqueKey(),
                    onPressed: () {
                      setState(() {
                        visble_form = false;
                      });
                    },
                    child: const Icon(Icons.close),
                    backgroundColor: Colors.red,
                  )
                : FloatingActionButton(
                    key: UniqueKey(),
                    onPressed: () {
                      setState(() {
                        visble_form = true;
                      });
                    },
                    child: const Icon(Icons.add),
                    backgroundColor: Colors.green,
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _filterProductsAdquiridos(String query) {
    setState(() {
      if (query.isNotEmpty) {
        productosPropios = _productosPropiosoriginalDetalles.where((detalle) {
          final articulo = detalle['fcProducto'].toString().toLowerCase();
          return articulo.contains(query.toLowerCase());
        }).toList();
      } else {
        productosPropios = List.from(_productosPropiosoriginalDetalles);
      }
    });
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isNotEmpty) {
        detallessinadquirir = _originaldetallesnoadd.where((detalle) {
          final articulo = detalle['fcProducto'].toString().toLowerCase();
          return articulo.contains(query.toLowerCase());
        }).toList();
      } else {
        detallessinadquirir = List.from(_originaldetallesnoadd);
      }
    });
  }

  List<Card> _buildCard() {
    return detallessinadquirir.map((detalle) {
      return Card(
        color: notifire.getbackcolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  imagen(context, detalle['NombreArchivo']!.toString(),
                      detalle['fcProducto']!.toString());
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: NetworkImage(detalle['NombreArchivo']),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      detalle['fcProducto'].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        color: notifire.getdarkscolor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      detalle['fcMarca'].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        color: notifire.getdarkgreycolor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showConfirmationDialog(
                        context,
                        detalle['NombreArchivo'].toString(),
                        detalle['fcProducto'].toString(),
                        detalle['RowNum'].toString(),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: notifire.getorangeprimerycolor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_circle_outline_outlined,
                          color: notifire.getdarkscolor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      );
    }).toList();
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, String img, String articulo, String id) async {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: notifire.getprimerycolor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: notifire.getprimerycolor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.6,
                maxWidth: screenWidth * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: screenHeight * 0.025),
                  Container(
                    width: screenWidth * 0.25,
                    height: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: NetworkImage(img),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  Center(
                    child: Text(
                      '¿Desea agregar a la solicitud el producto $articulo?',
                      style: TextStyle(
                        color: notifire.getdarkscolor,
                        fontFamily: 'Gilroy Bold',
                        fontSize: screenHeight * 0.02,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  GestureDetector(
                    onTap: () {
                      addSolicitudes(int.parse(id), articulo);
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: screenHeight * 0.08,
                      width: screenWidth * 0.5,
                      decoration: BoxDecoration(
                        color: notifire.getorangeprimerycolor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Agregar',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Gilroy Bold',
                            fontSize: screenHeight * 0.025,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: screenHeight * 0.08,
                      width: screenWidth * 0.5,
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
                            fontSize: screenHeight * 0.025,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataRow> _buildDataRows() {
    return productosPropios.map((detalle) {
      return DataRow(
        color: MaterialStateColor.resolveWith((states) =>
            _productosPropiosoriginalDetalles.indexOf(detalle) % 2 == 0
                ? Colors.white
                : const Color.fromARGB(255, 216, 215, 215)),
        cells: [
          DataCell(
            Text(detalle['RowNum']!.toString()),
          ),
          DataCell(IconButton(
            icon: const Icon(Icons.photo),
            onPressed: () {
              imagen(context, detalle['NombreArchivo']!.toString(),
                  detalle['fcProducto']!.toString());
            },
          )),
          DataCell(Text(detalle['fcProducto']!.toString())),
          DataCell(Text(detalle['fcMarca']!.toString())),
          DataCell(Text(detalle['fcTipoProducto']!.toString())),
        ],
      );
    }).toList();
  }

  void imagen(BuildContext context, String img, String nombre) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: const EdgeInsets.all(0),
            content: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: NetworkImage(img),
                  fit: BoxFit.contain,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        nombre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          overflow: TextOverflow.clip,
                          color: Color.fromARGB(255, 80, 79, 79),
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLessSolicitudDialog(
      BuildContext context, String img, String articulo, id) async {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: notifire.getprimerycolor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: notifire.getprimerycolor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.6,
                maxWidth: screenWidth * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: screenHeight * 0.025),
                  Container(
                    width: screenWidth * 0.25,
                    height: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: NetworkImage(img),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  Center(
                    child: Text(
                      '¿Desea cancelar solicitud del producto $articulo?',
                      style: TextStyle(
                        color: notifire.getdarkscolor,
                        fontFamily: 'Gilroy Bold',
                        fontSize: screenHeight * 0.02,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  GestureDetector(
                    onTap: () {
                      lessSolicitudes(id);
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: screenHeight * 0.08,
                      width: screenWidth * 0.5,
                      decoration: BoxDecoration(
                        color: notifire.getorangeprimerycolor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Confirmar',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Gilroy Bold',
                            fontSize: screenHeight * 0.025,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: screenHeight * 0.08,
                      width: screenWidth * 0.5,
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
                            fontSize: screenHeight * 0.025,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDialogSolicitudes() async {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero, // Eliminar el padding interno
          content: Container(
            width: screenWidth, // Ancho máximo
            height: screenHeight, // Alto máximo
            decoration: BoxDecoration(
              color: notifire.getprimerycolor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: notifire.getdarkscolor,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => notifire.getbluecolor),
                    labelColor: notifire.getdarkscolor,
                    dividerColor: MaterialStateColor.resolveWith(
                        (states) => notifire.getprimerycolor),
                    indicatorColor: notifire.getorangeprimerycolor,
                    tabs: const [
                      Tab(
                        text: 'Solicitud Actual',
                      ),
                      Tab(
                        text: 'Solicitudes',
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        solicitudes.isNotEmpty
                            ? Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      SendSolicitudNueva();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateColor.resolveWith(
                                              (states) => notifire
                                                  .getorangeprimerycolor),
                                    ),
                                    child: Text(
                                      'Realizar Solicitud',
                                      style: TextStyle(
                                          color: notifire.getdarkscolor),
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Column(
                                        children: _buildCardsDialog(),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                color: notifire.getbackcolor,
                                child: Center(
                                  child: Text(
                                    'No se han ingresado productos',
                                    style: TextStyle(
                                        color: notifire.getdarkscolor),
                                  ),
                                ),
                              ),
                        solicitudesHechas.isNotEmpty
                            ? Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Column(
                                        children: _buildSecondTabContent(),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                color: notifire.getbackcolor,
                                child: Center(
                                  child: Text(
                                    'No hay solicitudes disponibles',
                                    style: TextStyle(
                                        color: notifire.getdarkscolor),
                                  ),
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
      },
    );
  }

  Future<void> _showDetalles(List<dynamic> detalle) async {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            width:
                screenWidth * 0.9, // Ajustar el ancho del contenido del diálogo
            height: screenHeight *
                0.9, // Ajustar la altura del contenido del diálogo
            decoration: BoxDecoration(
              color: notifire.getprimerycolor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: notifire.getorangeprimerycolor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'DETALLES SOLICITUD #${detalle[0]['fiIDAdicionProduto']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: Text(
                //     'Título adicional', // Título adicional antes del listado
                //     style: TextStyle(
                //       color: notifire.getdarkscolor,
                //       fontSize: 16.0,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [..._detalles(detalle)],
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

  List<Card> _buildCardsDialog() {
    return solicitudes.map((detalle) {
      return Card(
        color: notifire.getbackcolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  imagen(context, detalle['NombreArchivo']!.toString(),
                      detalle['fcProducto']!.toString());
                },
                child: Container(
                  width: width * 0.2,
                  height: width * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: NetworkImage(detalle['NombreArchivo']),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      detalle['fcProducto'].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        color: notifire.getdarkscolor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      detalle['fcMarca'].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        color: notifire.getdarkgreycolor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showLessSolicitudDialog(
                          context,
                          detalle['NombreArchivo'],
                          detalle['fcProducto'],
                          detalle['RowNum']);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: notifire.getorangeprimerycolor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.remove_circle_outline_sharp,
                          color: notifire.getdarkscolor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Card> _buildSecondTabContent() {
    return solicitudesHechas.map((solicitud) {
      return Card(
        color: notifire.getbackcolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  image: const DecorationImage(
                    image: AssetImage('images/logos.png'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solicitud #${solicitud['fiIDAdicionProduto']}',
                      style: TextStyle(
                        fontSize: 16,
                        color: notifire.getdarkscolor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fecha de Solicitud: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(solicitud['fdFechadeSolicitud']))}',
                      style: TextStyle(
                        fontSize: 14,
                        color: notifire.getdarkscolor,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Solicitudes_AdicionProducto_ListadoDetalles(
                      solicitud['fiIDAdicionProduto']);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: notifire.getorangeprimerycolor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.info_outline,
                      color: notifire.getdarkscolor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Card> _detalles(List<dynamic> detalles) {
    final double width = MediaQuery.of(context).size.width;
    return detalles.map((detalle) {
      return Card(
        color: notifire.getbackcolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  imagen(context, detalle['NombreArchivo'].toString(),
                      detalle['fcProducto'].toString());
                },
                child: Container(
                  width: width * 0.2,
                  height: width * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: NetworkImage(detalle['NombreArchivo']),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      detalle['fcProducto'].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        color: notifire.getdarkscolor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      detalle['fcMarca'].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        color: notifire.getdarkgreycolor,
                      ),
                    ),
                    Text(
                      detalle['fcTipoProducto'].toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: notifire.getdarkgreycolor,
                      ),
                    ),
                    Text(
                      'Cantidad: ${detalle['fiCantidad']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: notifire.getdarkgreycolor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      );
    }).toList();
  }
}
