// ignore_for_file: non_constant_identifier_names, unused_import, prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, unnecessary_string_interpolations

import 'dart:convert';

import 'package:app_cliente_novanet/screens/pagoshome.dart';
import 'package:app_cliente_novanet/screens/referidos_screen.dart';
import 'package:app_cliente_novanet/utils/button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/api.dart';
import 'package:app_cliente_novanet/home/notifications.dart';
import 'package:app_cliente_novanet/profile/profile.dart';
import 'package:app_cliente_novanet/screens/payservice_screen.dart';
import 'package:app_cliente_novanet/screens/referir_screen.dart';
import 'package:app_cliente_novanet/screens/services_screen.dart';
import 'package:app_cliente_novanet/screens/webviewtest_screen.dart';
import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:app_cliente_novanet/utils/media.dart';
import 'package:app_cliente_novanet/utils/string.dart';
import 'package:flutter_credit_card/extension.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  final bool fbprincipal;
  const Home({Key? key, required this.fbprincipal}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late ColorNotifire notifire;
  late String selectedMonth;
  String fcNombreUsuario = '';
  String fcLlaveUnica = '';

  List produtosdelservicioactual = [];
  List json2 = [];
  List cuotas = [];

  bool _isExpanded = false;
  int _currentPage = 0;

  late AnimationController _controller;
  late Animation<double> _animation;

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //obtención de datos personales
    String fcNombreUsuarioFull = prefs.getString('fcNombreUsuario') ?? '';
    String key = prefs.getString('fcLlaveUnica') ?? '';

    List<String> parts = fcNombreUsuarioFull.split(' ');
    String fcNombreUsuarioFirstWord = parts.isNotEmpty ? parts.first : '';

    //json 4 : productos del cliente
    String dataAsString = prefs.getString('datalogin[3]') ?? '';

    //json 2 de información
    String dataAsString2 = prefs.getString('datalogin[1]') ?? '';

    var data2 = jsonDecode(dataAsString2);

    for (var cuota in data2) {
      cuotas.add(cuota["fnCuotaMensual"] ?? 0.00);
    }
    setState(() {
      produtosdelservicioactual = jsonDecode(dataAsString);
      json2 = jsonDecode(dataAsString2);
      fcNombreUsuario = fcNombreUsuarioFirstWord;
      fcLlaveUnica = key;
    });
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  late PageController _pageController;

  @override
  void initState() {
    _loadData();
    selectedMonth = '1';
    super.initState();
    _pageController = PageController();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < cuotas.length - 1) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: notifire.getorangeprimerycolor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              CustomStrings.hello + ' ' + fcNombreUsuario,
              style: TextStyle(
                  color: notifire.getwhite,
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  fontFamily: 'Gilroy'),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _launchUrlManual();
            },
            child: Icon(
              Icons.help_outline,
              color: notifire.getwhite,
              size: 24.0,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const Notificationindex("Notificaciones"),
                ),
              );
            },
           child:  json2[0]['fbNotificaciones']
          ? ScaleTransition(
              scale: _animation,
              child: Image.asset(
                "images/notification.png",
                color: Colors.white, // Puedes cambiarlo según el tema
                scale: 4,
              ),
            )
          : Image.asset(
              "images/notification.png",
              color: Colors.white,
              scale: 4,
            ),
          ),
          const SizedBox(
            width: 2,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Profile(fbprincipal: widget.fbprincipal),
                ),
              );
            },
            child: Image.asset(
              "images/user_outline.png",
              color: notifire.getwhite,
              scale: 20,
            ),
          ),
        ],
      ),
      backgroundColor: notifire.getprimerycolor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                          color: notifire.getprimerycolor,
                          child: Image.asset("images/backphoto.png")),
                      Column(
                        children: [
                          SizedBox(
                            height: height / 40,
                          ),
                          Center(
                            child: Container(
                              height: height / 10,
                              width: width / 1.2,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                color: notifire.getorangeprimerycolor,
                              ),
                              child: Stack(
                                children: [
                                  PageView.builder(
                                    controller: _pageController,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentPage = index;
                                      });
                                    },
                                    itemCount: cuotas.length,
                                    itemBuilder: (context, index) {
                                      bool hasAtraso = json2[index]
                                                  ['fcCuotasEnAtraso'] !=
                                              '' &&
                                          json2[index]['fitotal_debe'] != 0.00;

                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  hasAtraso
                                                      ? 'Cuota a Pagar Servicio #${json2[index]["fcIDPrestamo"].toString()}'
                                                      : 'Cuota Mensual Servicio #${json2[index]["fcIDPrestamo"].toString()}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: height / 50,
                                                    fontFamily: 'Gilroy Medium',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  hasAtraso
                                                      ? '${NumberFormat.currency(
                                                          locale: 'es',
                                                          symbol: '\$',
                                                        ).format(json2[index]['fitotal_debe'])}'
                                                      : NumberFormat.currency(
                                                          locale: 'es',
                                                          symbol: '\$',
                                                        ).format(cuotas[index]),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: height / 35,
                                                    fontFamily: 'Gilroy Bold',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (hasAtraso)
                                            Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${json2[index]['fcCuotasEnAtraso']}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: height / 60,
                                                      fontFamily:
                                                          'Gilroy Medium',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          else if (json2[index]
                                                  ['fdFechaProximoPago'] !=
                                              null)
                                            Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Próximo Pago: ${DateFormat('dd/MM/yyyy').format(
                                                      DateTime.parse(
                                                        json2[index][
                                                            'fdFechaProximoPago'],
                                                      ),
                                                    )}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: height / 60,
                                                      fontFamily:
                                                          'Gilroy Medium',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                  if (_currentPage > 0)
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: IconButton(
                                        icon: const Icon(
                                            Icons.arrow_back_ios_new,
                                            color: Colors.white),
                                        onPressed: _previousPage,
                                      ),
                                    ),
                                  if (_currentPage < cuotas.length - 1)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: IconButton(
                                        icon: const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Colors.white),
                                        onPressed: _nextPage,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: width / 38),
                              child: Container(
                                height: height / 7,
                                width: width,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: notifire.getwhite,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: notifire.getdarkscolor
                                          .withOpacity(0.3),
                                      blurRadius: 5.0,
                                      offset: const Offset(0.0, 0.75),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: height / 50,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (widget.fbprincipal) ...[
                                          _buildIconButton(
                                            context,
                                            "images/referir.png",
                                            CustomStrings.referir,
                                            () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const referidos_Screen(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                        _buildIconButton(
                                          context,
                                          "images/high-speed.png",
                                          'Test',
                                          () {
                                            if (fcLlaveUnica.isNullOrEmpty ||
                                                fcLlaveUnica == '') {
                                              CherryToast.info(
                                                backgroundColor:
                                                    notifire.getbackcolor,
                                                title: Text(
                                                    'Aún no cuentas con esta opción',
                                                    style: TextStyle(
                                                        color: notifire
                                                            .getdarkscolor),
                                                    textAlign: TextAlign.start),
                                                borderRadius: 5,
                                              ).show(context);
                                              return;
                                            }
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const WebviewTest_screen(),
                                              ),
                                            );
                                          },
                                        ),
                                        _buildIconButton(
                                          context,
                                          "images/apoyo.png",
                                          'Comunícate',
                                          () {
                                            _showWPDialog(context);
                                          },
                                        ),
                                        _buildIconButton(
                                          context,
                                          "images/caja.png",
                                          CustomStrings.addservice,
                                          () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddServices_Screen(
                                                  'Servicios',
                                                  fbprincipal:
                                                      widget.fbprincipal,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        _buildIconButton(
                                          context,
                                          "images/pagar.png",
                                          CustomStrings.pay,
                                          () {
                                            if (fcLlaveUnica.isNullOrEmpty ||
                                                fcLlaveUnica == '') {
                                              CherryToast.info(
                                                backgroundColor:
                                                    notifire.getbackcolor,
                                                title: Text(
                                                    'Aún no cuentas con esta opción',
                                                    style: TextStyle(
                                                        color: notifire
                                                            .getdarkscolor),
                                                    textAlign: TextAlign.start),
                                                borderRadius: 5,
                                              ).show(context);
                                              return;
                                            }
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PayWebview_screen(
                                                        keyId: fcLlaveUnica),
                                              ),
                                            );
                                          },
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
                    ],
                  ),
                  SizedBox(
                    height: height / 30,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / 18),
                    child: Row(
                      children: [
                        Text(
                          CustomStrings.service,
                          style: TextStyle(
                              fontFamily: "Gilroy Bold",
                              color: notifire.getdarkscolor,
                              fontSize: height / 40),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height / 50,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: json2.length,
                    itemBuilder: (context, index) {
                      List detalles = json.decode(json2[index]["Detalles"]);

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.05,
                          vertical: height * 0.01,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
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
                            child: ExpansionTile(
                              initiallyExpanded: false,
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
                                          width: height * 0.07,
                                          decoration: BoxDecoration(
                                            color: notifire.getprimerycolor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.wifi,
                                              color: notifire.getdarkscolor,
                                              size: height * 0.035,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: width * 0.02),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: height * 0.01),
                                              Text(
                                                "Estado Actual de Servicio #${json2[index]["fcIDPrestamo"].toString()}",
                                                style: TextStyle(
                                                  fontFamily: "Gilroy Bold",
                                                  color: notifire.getdarkscolor,
                                                  fontSize: height * 0.015,
                                                ),
                                              ),
                                              SizedBox(height: height * 0.005),
                                              Text(
                                                'Fecha Inicio Servicio: ' +
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(
                                                      DateTime.parse(
                                                        json2[index][
                                                                "fdFechaCreacionSolicitud"]
                                                            .toString(),
                                                      ),
                                                    ),
                                                style: TextStyle(
                                                  fontFamily: "Gilroy Medium",
                                                  color: notifire.getdarkscolor
                                                      .withOpacity(0.6),
                                                  fontSize: height * 0.013,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: width * 0.02),
                                        Column(
                                          children: [
                                            SizedBox(height: height * 0.04),
                                            Text(
                                              // json2[index]["fcEstadoSolicitud"]
                                              //     .toString(),
                                              'Activo',
                                              style: TextStyle(
                                                fontFamily: "Gilroy Bold",
                                                color: Colors.green,
                                                fontSize: height * 0.02,
                                              ),
                                            ),
                                            SizedBox(height: height * 0.04),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: height * 0.005),
                                  ],
                                ),
                              ),
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: width * 0.02,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildDetailRow(
                                                    "Plazo Seleccionado",
                                                    json2[index][
                                                            "fiPlazoSeleccionado"]
                                                        .toString()),
                                                const SizedBox(height: 10),
                                                _buildDetailRow(
                                                    "Departamento",
                                                    json2[index]
                                                            ["fcDepartamento"]
                                                        .toString()),
                                                const SizedBox(height: 10),
                                                _buildDetailRow(
                                                    "Municipio",
                                                    json2[index]["fcMunicipio"]
                                                        .toString()),
                                                const SizedBox(height: 10),
                                                _buildDetailRow(
                                                    "Barrio",
                                                    json2[index]["fcBarrio"]
                                                        .toString()),
                                                const SizedBox(height: 10),
                                                _buildDetailRow(
                                                    "Dirección Exacta",
                                                    json2[index][
                                                            "fcDireccionDetallada"]
                                                        .toString()
                                                        .toUpperCase()),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.02),
                                  child: Text(
                                    'Productos',
                                    style: TextStyle(
                                      fontFamily: "Gilroy Medium",
                                      color: notifire.getdarkscolor
                                          .withOpacity(0.6),
                                      fontSize: height * 0.013,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.02),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: (detalles.length / 2).ceil(),
                                        itemBuilder: (context, detallesIndex) {
                                          int firstIndex = detallesIndex * 2;
                                          int secondIndex = firstIndex + 1;

                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: height * 0.01),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // First Column
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_ios_rounded,
                                                        color: notifire
                                                            .getdarkscolor,
                                                        size: 10,
                                                      ),
                                                      SizedBox(
                                                          width: width * 0.02),
                                                      Expanded(
                                                        child: Text(
                                                          detalles[firstIndex]
                                                              ["fcProducto"],
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "Gilroy Medium",
                                                            color: notifire
                                                                .getdarkscolor
                                                                .withOpacity(
                                                                    0.6),
                                                            fontSize:
                                                                height * 0.013,
                                                            letterSpacing: 1.5,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          softWrap: true,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: width * 0.02),
                                                // Second Column
                                                Expanded(
                                                  child: secondIndex <
                                                          detalles.length
                                                      ? Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_ios_rounded,
                                                              color: notifire
                                                                  .getdarkscolor,
                                                              size: 10,
                                                            ),
                                                            SizedBox(
                                                                width: width *
                                                                    0.02),
                                                            Expanded(
                                                              child: Text(
                                                                detalles[
                                                                        secondIndex]
                                                                    [
                                                                    "fcProducto"],
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      "Gilroy Medium",
                                                                  color: notifire
                                                                      .getdarkscolor
                                                                      .withOpacity(
                                                                          0.6),
                                                                  fontSize:
                                                                      height *
                                                                          0.013,
                                                                  letterSpacing:
                                                                      1.5,
                                                                ),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : Container(),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: height / 80,
                  ),
                  Column(
                    children: [PagosPage()],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showWPDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(
                      'images/fondo.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.fbprincipal) {
                          _showWPDialogNumeroTexto(context, 'SOPORTE');
                        } else {
                          _showWPDialogNumero(context, 'SOPORTE');
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Image(
                              image: AssetImage('images/wp.png'),
                              height: 20,
                              width: 20,
                            ),
                            SizedBox(width: 1),
                            Text(
                              'SOPORTE TÉCNICO ',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Gilroy Bold',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.fbprincipal) {
                          _showWPDialogNumeroTexto(context, 'PAGOS');
                        } else {
                          _showWPDialogNumero(context, 'PAGOS');
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Image(
                              image: AssetImage('images/wp.png'),
                              height: 20,
                              width: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'SOPORTE PAGOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Gilroy Bold',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.fbprincipal) {
                          _showWPDialogNumeroTexto(context, 'CONTRATAR');
                        } else {
                          _showWPDialogNumero(context, 'CONTRATAR');
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Image(
                              image: AssetImage('images/wp.png'),
                              height: 20,
                              width: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'CONTRATAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Gilroy Bold',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: "Gilroy Medium",
                            color: notifire.getdarkscolor.withOpacity(0.6),
                            fontSize: height * 0.013,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontFamily: "Gilroy Medium",
                            color: notifire.getdarkscolor.withOpacity(0.6),
                            fontSize: height * 0.013,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showWPDialogNumeroTexto(BuildContext context, opcion) async {
    TextEditingController Texto = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('images/fondo.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ingrese un comentario',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Gilroy Bold',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextField(
                      controller: Texto,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Comentario',
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        final texto = Texto.text;
                        if (texto.isEmpty) {
                          CherryToast.warning(
                            backgroundColor: notifire.getbackcolor,
                            title: Text('Necesita Ingresar un comentario',
                                style: TextStyle(color: notifire.getdarkscolor),
                                textAlign: TextAlign.start),
                            borderRadius: 5,
                          ).show(context);
                          return;
                        }

                        _launchUrl(opcion, texto);
                        Navigator.of(context).pop();
                      },
                      child: Custombutton.button(notifire.getorangeprimerycolor,
                          'Confirmar', width / 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showWPDialogNumero(BuildContext context, opcion) async {
    TextEditingController NumeroIngresado = TextEditingController();
    TextEditingController Texto = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('images/fondo.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ingrese el número de teléfono al cual desea se le contacte',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Gilroy Bold',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextField(
                      controller: NumeroIngresado,
                      maxLength: 8,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Número de teléfono',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextField(
                      controller: Texto,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Comentario',
                      ),
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        final texto = Texto.text;
                        final numero = NumeroIngresado.text;
                        if (numero.isEmpty) {
                          CherryToast.warning(
                            backgroundColor: notifire.getbackcolor,
                            title: Text('Ingrese un numero de teléfono',
                                style: TextStyle(color: notifire.getdarkscolor),
                                textAlign: TextAlign.start),
                            borderRadius: 5,
                          ).show(context);
                          return;
                        }
                        if (numero.length != 8) {
                          CherryToast.warning(
                            backgroundColor: notifire.getbackcolor,
                            title: Text('Son necesarios 8 digitos',
                                style: TextStyle(color: notifire.getdarkscolor),
                                textAlign: TextAlign.start),
                            borderRadius: 5,
                          ).show(context);
                          return;
                        }
                        if (texto.isEmpty) {
                          CherryToast.warning(
                            backgroundColor: notifire.getbackcolor,
                            title: Text('Necesita Ingresar un comentario',
                                style: TextStyle(color: notifire.getdarkscolor),
                                textAlign: TextAlign.start),
                            borderRadius: 5,
                          ).show(context);
                          return;
                        }
                        _launchUrlSecundario(opcion, numero, texto);
                        Navigator.of(context).pop();
                      },
                      child: Custombutton.button(notifire.getorangeprimerycolor,
                          'Confirmar', width / 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String opcion, comentario) async {
    final prefs = await SharedPreferences.getInstance();
    var fcNumeroTelefono = prefs.getString("fcTelefono");

    final Uri apiUrl =
        Uri.parse('https://srv2.rob.chat/REST_API/Tickets/Nuevo/');

    final headers = {
      'key': '8cbea7517da189fdcd89ff68dac8e67c',
      'pushId': '',
      'token': '',
      'Content-Type': 'application/json',
    };

    var requestBody = {
      'key': '8cbea7517da189fdcd89ff68dac8e67c',
      'grupo': opcion,
      'telefono': '504$fcNumeroTelefono',
      'texto':
          'Hola tu referencia es %Ticket%, dentro de un momento un agente te contactará.',
      'pushId': '15',
      'token': 'RC15',
      'variables': {
        'comentario': '$comentario',
      },
    };

    String jsonRequestBody = jsonEncode(requestBody);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: CircularProgressIndicator(
                color: notifire.getorangeprimerycolor));
      },
    );

    try {
      final response = await http.post(
        apiUrl,
        body: jsonRequestBody,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (kDebugMode) {
          print(json);
        }

        String Url =
            "https://api.whatsapp.com/send/?phone=50489081273&text=Buen+dia&type=phone_number&app_absent=0";

        Navigator.of(context).pop();

        if (!await launchUrl(Uri.parse(Url))) {
          throw Exception('Could not launch $Url');
        }
      } else {
        Navigator.of(context).pop();
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context).pop();
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _launchUrlSecundario(
      String opcion, String numerodetelefonoingresado, comentario) async {
    final prefs = await SharedPreferences.getInstance();
    var fcNumeroTelefono = prefs.getString("fcTelefono");
    var fcIdentidad = prefs.getString("fcIdentidad");

    final Uri apiUrl =
        Uri.parse('https://srv2.rob.chat/REST_API/Tickets/Nuevo/');

    final headers = {
      'key': '8cbea7517da189fdcd89ff68dac8e67c',
      'pushId': '',
      'token': '',
      'Content-Type': 'application/json',
    };

    var requestBody = {
      'key': '8cbea7517da189fdcd89ff68dac8e67c',
      'grupo': opcion,
      'telefono': '504$numerodetelefonoingresado',
      'pushId': '15',
      'token': 'RC15',
      'texto':
          'Hola tu referencia es %Ticket%, dentro de un momento un agente te contactará.',
      'variables': {
        'identidad': '$fcIdentidad',
        'nombre_completo': fcNombreUsuario,
        'comentario': '$comentario',
      },
    };
    if (kDebugMode) {
      print(requestBody);
    }

    String jsonRequestBody = jsonEncode(requestBody);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: CircularProgressIndicator(
          color: notifire.getorangeprimerycolor,
        ));
      },
    );

    try {
      final response = await http.post(
        apiUrl,
        body: jsonRequestBody,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (kDebugMode) {
          print(json);
        }

        String Url =
            "https://api.whatsapp.com/send/?phone=50489081273&text=Buen+dia&type=phone_number&app_absent=0";

        Navigator.of(context).pop();

        if (!await launchUrl(Uri.parse(Url))) {
          throw Exception('Could not launch $Url');
        }
      } else {
        Navigator.of(context).pop();
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context).pop();
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Widget _buildIconButton(BuildContext context, String imagePath, String label,
      VoidCallback onTap) {
    return Flexible(
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: height / 15,
              width: width / 7,
              decoration: BoxDecoration(
                color: notifire.getprimerycolor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26, // Sombra con el color #faa61a
                    blurRadius: 15.0,
                    offset: const Offset(0.0, 0.5),
                    spreadRadius:
                        0.12, // Aumenta el radio de dispersión de la sombra
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  imagePath,
                  color: Color(0xFFfaa61a),
                  height: height / 20,
                ),
              ),
            ),
          ),
          SizedBox(
            height: height / 60,
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: "Gilroy Bold",
              color: notifire.getdarkscolor,
              fontSize: height / 70,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrlManual() async {
    if (!await launchUrl(
        Uri.parse('https://novanetgroup.com/NovanetApp/Manuales/Index.html'))) {
      throw Exception(
          'Could not launch https://novanetgroup.com/NovanetApp/Manuales/Index.html');
    }
  }
}
