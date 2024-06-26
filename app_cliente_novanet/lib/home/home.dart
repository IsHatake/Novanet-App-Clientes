// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert';

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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ColorNotifire notifire;
  late String selectedMonth;
  String fcNombreUsuario = '';
  List produtosdelservicioactual = [];
  List json2 = [];
  List listadodepagos = [];
  bool _isExpanded = false;
  double CuotaMensual = 0.00;

  late final listadodepagosoriginal = List.from(listadodepagos);

  Future<void> _loadData() async {
    double sumaCuotas = 0.00;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //obtención de datos personales
    String fcNombreUsuarioFull = prefs.getString('fcNombreUsuario') ?? '';
    List<String> parts = fcNombreUsuarioFull.split(' ');
    String fcNombreUsuarioFirstWord = parts.isNotEmpty ? parts.first : '';

    //json 4 : productos del cliente
    String dataAsString = prefs.getString('datalogin[3]') ?? '';

    //json 2 de información
    String dataAsString2 = prefs.getString('datalogin[1]') ?? '';

    String pagos = prefs.getString('datalogin[4]') ?? '';

    var data2 = jsonDecode(dataAsString2);

    for (var cuota in data2) {
      sumaCuotas += cuota["fnCuotaMensual"] ?? 0.00;
    }
    setState(() {
      produtosdelservicioactual = jsonDecode(dataAsString);
      json2 = jsonDecode(dataAsString2);
      listadodepagos = jsonDecode(pagos);
      fcNombreUsuario = fcNombreUsuarioFirstWord;
      CuotaMensual = sumaCuotas;
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

  void filtrarPagos(String? mes) {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);

    List<dynamic> filteredList = [];

    if (mes == '1') {
      // filteredList = listadodepagosoriginal.where((pago) {
      //   DateTime fechaTransaccion = DateTime.parse(pago['fdFechaTransaccion']);
      //   return fechaTransaccion.year == now.year &&
      //       fechaTransaccion.month == now.month;
      // }).toList();
      // setState(() {
      //   listadodepagos = filteredList;
      // });1301198000105
      setState(() {
        listadodepagos = List.from(listadodepagosoriginal);
      });
    } else if (mes == '2') {
      DateTime threeMonthsAgo =
          firstDayOfMonth.subtract(const Duration(days: 90));
      filteredList = listadodepagosoriginal.where((pago) {
        DateTime fechaTransaccion = DateTime.parse(pago['fdFechaTransaccion']);
        return fechaTransaccion.isAfter(threeMonthsAgo) ||
            fechaTransaccion.isAtSameMomentAs(firstDayOfMonth);
      }).toList();
      setState(() {
        listadodepagos = filteredList;
      });
    } else if (mes == '3') {
      DateTime sixMonthsAgo =
          firstDayOfMonth.subtract(const Duration(days: 180));
      filteredList = listadodepagosoriginal.where((pago) {
        DateTime fechaTransaccion = DateTime.parse(pago['fdFechaTransaccion']);
        return fechaTransaccion.isAfter(sixMonthsAgo) ||
            fechaTransaccion.isAtSameMomentAs(firstDayOfMonth);
      }).toList();
      setState(() {
        listadodepagos = filteredList;
      });
    } else {
      setState(() {
        listadodepagos = List.from(listadodepagosoriginal);
      });
    }
  }

  @override
  void initState() {
    _loadData();
    selectedMonth = '1';
    super.initState();
  }

  String _getMonthName(int op) {
    switch (op) {
      case 1:
        return CustomStrings.op1;
      case 2:
        return CustomStrings.op2;
      case 3:
        return CustomStrings.op3;
      default:
        return '';
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
                  fontSize: 20,
                  fontFamily: 'Gilroy'),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const Notificationindex(CustomStrings.notification),
                ),
              );
            },
            child: Image.asset(
              "images/notification.png",
              color: notifire.getwhite,
              scale: 4,
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
                  builder: (context) => const WebviewTest_screen(),
                ),
              );
            },
            child: Image.asset(
              "images/high-speed.png",
              color: notifire.getwhite,
              scale: 20,
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
                  builder: (context) => const Profile(),
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
                          color: notifire.getbackcolor,
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Cuota Mensual",
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
                                          NumberFormat.currency(
                                            locale: 'es',
                                            symbol: '\$',
                                          ).format(
                                            double.parse(
                                              CuotaMensual.toString(),
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: height / 35,
                                            fontFamily: 'Gilroy Bold',
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
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
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Scan(),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: height / 15,
                                                width: width / 7,
                                                decoration: BoxDecoration(
                                                  color:
                                                      notifire.getprimerycolor,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                  boxShadow: const <BoxShadow>[
                                                    BoxShadow(
                                                      color: Color.fromARGB(
                                                          34, 82, 79, 79),
                                                      blurRadius: 15.0,
                                                      offset: Offset(0.0, 0.75),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Image.asset(
                                                    "images/metodo-de-pago.png",
                                                    color:
                                                        notifire.getdarkscolor,
                                                    height: height / 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: height / 60,
                                            ),
                                            Text(
                                              CustomStrings.pay,
                                              style: TextStyle(
                                                  fontFamily: "Gilroy Bold",
                                                  color: notifire.getdarkscolor,
                                                  fontSize: height / 55),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 20.00,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _showWPDialog(context);
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                height: height / 15,
                                                width: width / 7,
                                                decoration: BoxDecoration(
                                                  color:
                                                      notifire.getprimerycolor,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                  boxShadow: const <BoxShadow>[
                                                    BoxShadow(
                                                      color: Color.fromARGB(
                                                          34, 82, 79, 79),
                                                      blurRadius: 15.0,
                                                      offset: Offset(0.0, 0.75),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Image.asset(
                                                    "images/apoyo.png",
                                                    color:
                                                        notifire.getdarkscolor,
                                                    height: height / 20,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: height / 60,
                                              ),
                                              Text(
                                                CustomStrings.soporte,
                                                style: TextStyle(
                                                  fontFamily: "Gilroy Bold",
                                                  color: notifire.getdarkscolor,
                                                  fontSize: height / 55,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20.00,
                                        ),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const AddServices_Screen(
                                                            'Servicios'),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: height / 15,
                                                width: width / 7,
                                                decoration: BoxDecoration(
                                                  color:
                                                      notifire.getprimerycolor,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                  boxShadow: const <BoxShadow>[
                                                    BoxShadow(
                                                      color: Color.fromARGB(
                                                          34, 82, 79, 79),
                                                      blurRadius: 15.0,
                                                      offset: Offset(0.0, 0.75),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Image.asset(
                                                    "images/caja.png",
                                                    color:
                                                        notifire.getdarkscolor,
                                                    height: height / 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: height / 60,
                                            ),
                                            Text(
                                              CustomStrings.addservice,
                                              style: TextStyle(
                                                  fontFamily: "Gilroy Bold",
                                                  color: notifire.getdarkscolor,
                                                  fontSize: height / 55),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 20.00,
                                        ),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ReferirScreen(),
                                                  ),
                                                );

                                                // CherryToast.info(
                                                //   backgroundColor:
                                                //       notifire.getbackcolor,
                                                //   title: Text('En Proceso',
                                                //       style: TextStyle(
                                                //           color: notifire
                                                //               .getdarkscolor),
                                                //       textAlign:
                                                //           TextAlign.start),
                                                //   borderRadius: 5,
                                                // ).show(context);
                                              },
                                              child: Container(
                                                height: height / 15,
                                                width: width / 7,
                                                decoration: BoxDecoration(
                                                  color:
                                                      notifire.getprimerycolor,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                  boxShadow: const <BoxShadow>[
                                                    BoxShadow(
                                                      color: Color.fromARGB(
                                                          34, 82, 79, 79),
                                                      blurRadius: 15.0,
                                                      offset: Offset(0.0, 0.75),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Image.asset(
                                                    "images/referir.png",
                                                    color:
                                                        notifire.getdarkscolor,
                                                    height: height / 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: height / 60,
                                            ),
                                            Text(
                                              CustomStrings.referir,
                                              style: TextStyle(
                                                  fontFamily: "Gilroy Bold",
                                                  color: notifire.getdarkscolor,
                                                  fontSize: height / 55),
                                            ),
                                            const SizedBox(
                                              width: 20.00,
                                            ),
                                          ],
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
                  Padding(
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
                                        borderRadius: BorderRadius.circular(10),
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
                                            "Estado Actual de Servicio",
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
                                                    .format(DateTime.parse(
                                                  json2[0][
                                                          "fdFechaCreacionSolicitud"]
                                                      .toString(),
                                                )),
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
                                          json2[0]["fcEstadoSolicitud"]
                                              .toString(),
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
                                            horizontal: width * 0.02),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Plazo Seleccionado',
                                                  style: TextStyle(
                                                    fontFamily: "Gilroy Medium",
                                                    color: notifire
                                                        .getdarkscolor
                                                        .withOpacity(0.6),
                                                    fontSize: height * 0.013,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Departamento',
                                                  style: TextStyle(
                                                    fontFamily: "Gilroy Medium",
                                                    color: notifire
                                                        .getdarkscolor
                                                        .withOpacity(0.6),
                                                    fontSize: height * 0.013,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Municipio',
                                                  style: TextStyle(
                                                    fontFamily: "Gilroy Medium",
                                                    color: notifire
                                                        .getdarkscolor
                                                        .withOpacity(0.6),
                                                    fontSize: height * 0.013,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Barrio',
                                                  style: TextStyle(
                                                    fontFamily: "Gilroy Medium",
                                                    color: notifire
                                                        .getdarkscolor
                                                        .withOpacity(0.6),
                                                    fontSize: height * 0.013,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Dirección Exacta',
                                                  style: TextStyle(
                                                    fontFamily: "Gilroy Medium",
                                                    color: notifire
                                                        .getdarkscolor
                                                        .withOpacity(0.6),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: width * 0.02),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  json2[0][
                                                          "fiPlazoSeleccionado"]
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontFamily: "Gilroy Medium",
                                                    color: notifire
                                                        .getdarkscolor
                                                        .withOpacity(0.6),
                                                    fontSize: height * 0.013,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Align(
                                                alignment: Alignment
                                                    .centerLeft, // Centrado vertical
                                                child: Text(
                                                  json2[0]["fcDepartamento"]
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontFamily: "Gilroy Medium",
                                                    color: notifire
                                                        .getdarkscolor
                                                        .withOpacity(0.6),
                                                    fontSize: height * 0.013,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  json2[0]["fcMunicipio"]
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontFamily: "Gilroy Medium",
                                                    color: notifire
                                                        .getdarkscolor
                                                        .withOpacity(0.6),
                                                    fontSize: height * 0.013,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  json2[0]["fcBarrio"]
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontFamily: "Gilroy Medium",
                                                    color: notifire
                                                        .getdarkscolor
                                                        .withOpacity(0.6),
                                                    fontSize: height * 0.013,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  json2[0][
                                                          "fcDireccionDetallada"]
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontFamily: "Gilroy Medium",
                                                    color: notifire
                                                        .getdarkscolor
                                                        .withOpacity(0.6),
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
                            ),
                            const Divider(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.02),
                              child: Text(
                                'Productos',
                                style: TextStyle(
                                  fontFamily: "Gilroy Medium",
                                  color:
                                      notifire.getdarkscolor.withOpacity(0.6),
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
                                    itemCount: produtosdelservicioactual.length,
                                    itemBuilder: (context, index) => Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: height * 0.01),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                color: notifire.getdarkscolor,
                                                size: 10,
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: width * 0.02),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                produtosdelservicioactual[index]
                                                    ["fcProducto"],
                                                style: TextStyle(
                                                  fontFamily: "Gilroy Medium",
                                                  color: notifire.getdarkscolor
                                                      .withOpacity(0.6),
                                                  fontSize: height * 0.013,
                                                  letterSpacing: 1.5,
                                                ),
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
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height / 80,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / 18),
                    child: Row(
                      children: [
                        selectedMonth == '1'
                            ? Flexible(
                                child: Text(
                                  _getMonthName(int.parse(selectedMonth)),
                                  style: TextStyle(
                                    fontFamily: "Gilroy Bold",
                                    color: notifire.getdarkscolor,
                                    fontSize: height / 40,
                                  ),
                                  overflow: TextOverflow.fade,
                                ),
                              )
                            : Flexible(
                                child: Text(
                                  'Pagos de ${_getMonthName(int.parse(selectedMonth))}',
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
                          dropdownColor: notifire.getprimerycolor,
                          onChanged: (String? newValue) {
                            filtrarPagos(newValue);
                            setState(() {
                              selectedMonth = newValue!;
                            });
                          },
                          items: <String>[
                            for (int i = 1; i <= 3; i++) i.toString()
                          ].map<DropdownMenuItem<String>>((String value) {
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
                  ),
                  SizedBox(
                    height: height / 50,
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height,
                          color: Colors.transparent,
                          child: listadodepagos.isEmpty
                              ? SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "images/sin-dinero.png",
                                        color: notifire.getorangeprimerycolor,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.10,
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
                                  itemBuilder: (context, index) => Padding(
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: height * 0.07,
                                                    width: width / 7,
                                                    decoration: BoxDecoration(
                                                      color: notifire
                                                          .getprimerycolor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        listadodepagos[index][
                                                                    'fiIDTransaccion']
                                                                .toString() +
                                                            ' - ' +
                                                            listadodepagos[
                                                                    index]
                                                                ['fcOperacion'],
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Gilroy Bold",
                                                          color: notifire
                                                              .getdarkscolor,
                                                          fontSize:
                                                              height * 0.015,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(
                                                          height:
                                                              height * 0.005),
                                                      Text(
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(
                                                          DateTime.parse(
                                                            listadodepagos[
                                                                    index][
                                                                'fdFechaTransaccion'],
                                                          ),
                                                        ),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Gilroy Medium",
                                                          color: notifire
                                                              .getdarkscolor
                                                              .withOpacity(0.6),
                                                          fontSize:
                                                              height * 0.013,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height:
                                                              height * 0.005),
                                                      Text(
                                                        NumberFormat.currency(
                                                          locale: 'es',
                                                          symbol: '\$',
                                                        ).format(
                                                          double.parse(
                                                            listadodepagos[
                                                                        index][
                                                                    'fnValorAbonado']
                                                                .toString(),
                                                          ),
                                                        ),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Gilroy Bold",
                                                          color: notifire
                                                              .getdarkscolor,
                                                          fontSize:
                                                              height * 0.02,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: height * 0.005),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ]),
                  SizedBox(
                    height: height / 20,
                  ),
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
                    onTap: () => _launchUrl('SOPORTE'),
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
                            'SOPORTE',
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
                    onTap: () => _launchUrl('PAGOS'),
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
                            'PAGOS',
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
                    onTap: () => _launchUrl('CONTRATAR'),
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


  Future<void> _launchUrl(String opcion) async {
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
      'pushId': '15',
      'token': 'RC15'
    };

    String jsonRequestBody = jsonEncode(requestBody);

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
          "https://api.whatsapp.com/send/?phone=50489081273&text=Hola&type=phone_number&app_absent=0";
      if (!await launchUrl(Uri.parse(Url))) {
        throw Exception('Could not launch $Url');
      }
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }
}
