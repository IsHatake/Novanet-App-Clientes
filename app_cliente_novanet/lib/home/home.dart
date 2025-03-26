import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_cliente_novanet/screens/chat_screen.dart';
import 'package:app_cliente_novanet/screens/pagoshome.dart';
import 'package:app_cliente_novanet/screens/payment_screen.dart';
import 'package:app_cliente_novanet/screens/referidos_screen.dart';
import 'package:app_cliente_novanet/screens/payservice_screen.dart';
import 'package:app_cliente_novanet/screens/referir_screen.dart';
import 'package:app_cliente_novanet/screens/services_screen.dart';
import 'package:app_cliente_novanet/screens/webviewtest_screen.dart';
import 'package:app_cliente_novanet/service/signalRChat_Service.dart';
import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:app_cliente_novanet/utils/button.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:app_cliente_novanet/utils/string.dart';
import 'package:app_cliente_novanet/home/notifications.dart';
import 'package:app_cliente_novanet/profile/profile.dart';
import 'package:app_cliente_novanet/screens/dialogPagoWidget.dart';

class Home extends StatefulWidget {
  final bool fbprincipal;
  const Home({Key? key, required this.fbprincipal}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late ColorNotifire notifire;
  String fcNombreUsuario = '';
  String fcLlaveUnica = '';
  List productosDelServicioActual = [];
  List json2 = [];
  List<double> cuotas = [];
  bool _isExpanded = false;
  int _currentPage = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pageController = PageController();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fcNombreUsuarioFull = prefs.getString('fcNombreUsuario') ?? '';
      final key = prefs.getString('fcLlaveUnica') ?? '';
      final dataAsString = prefs.getString('datalogin[3]') ?? '[]';
      final dataAsString2 = prefs.getString('datalogin[1]') ?? '[]';

      final data2 = jsonDecode(dataAsString2) as List<dynamic>;
      setState(() {
        fcNombreUsuario = fcNombreUsuarioFull.split(' ').first;
        fcLlaveUnica = key;
        productosDelServicioActual = jsonDecode(dataAsString);
        json2 = data2;
        cuotas = json2.isNotEmpty
            ? data2
                .map<double>((cuota) => (cuota["fnCuotaMensual"] ?? 0.0) as double)
                .toList()
            : [];
      });
    } catch (e) {
      CherryToast.error(
        title: const Text('Error al cargar datos'),
      ).show(context);
      debugPrint('Error in _loadData: $e');
    }
  }

  void _navigatePage(int direction) {
    if (_currentPage + direction >= 0 &&
        _currentPage + direction < cuotas.length) {
      setState(() {
        _currentPage += direction;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: notifire.getorangeprimerycolor,
        title: Text(
          '${CustomStrings.hello} $fcNombreUsuario',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 18,
            fontFamily: 'Gilroy',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: notifire.getwhite),
            onPressed: () => _launchUrlManual(
                'https://novanetgroup.com/NovanetApp/Manuales/Index.html'),
          ),
          IconButton(
            icon: json2.isNotEmpty && json2[0]['fbNotificaciones'] == true
                ? ScaleTransition(scale: _animation, child: _notificationIcon())
                : _notificationIcon(),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const Notificationindex("Notificaciones")),
            ),
          ),
          IconButton(
            icon: Image.asset("images/user_outline.png",
                color: notifire.getwhite, scale: 20),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => Profile(fbprincipal: widget.fbprincipal)),
            ),
          ),
        ],
      ),
      backgroundColor: notifire.getprimerycolor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(height, width),
            _buildServiceSection(height, width),
            const PagosPage(),
          ],
        ),
      ),
    );
  }

  Widget _notificationIcon() => Image.asset(
        "images/notification.png",
        color: notifire.getwhite,
        scale: 4,
      );

  Widget _buildHeader(double height, double width) => Stack(
        children: [
          Image.asset("images/backphoto.png", fit: BoxFit.cover),
          Column(
            children: [
              SizedBox(height: height / 40),
              _buildPaymentCard(height, width),
              _buildIconButtons(height, width),
            ],
          ),
        ],
      );

  Widget _buildPaymentCard(double height, double width) => Center(
        child: Container(
          height: height / 10,
          width: width / 1.2,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            color: notifire.getorangeprimerycolor,
          ),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: cuotas.length,
                itemBuilder: (_, index) => _buildPaymentInfo(index, height),
              ),
              if (_currentPage > 0)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: _buildNavigationButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => _navigatePage(-1),
                    isLeft: true,
                  ),
                ),
              if (_currentPage < cuotas.length - 1)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: _buildNavigationButton(
                    icon: Icons.arrow_forward_ios_rounded,
                    onPressed: () => _navigatePage(1),
                    isLeft: false,
                  ),
                ),
              Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                child: _buildPageIndicators(),
              ),
            ],
          ),
        ),
      );

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isLeft,
  }) {
    return SizedBox(
      width: 36,
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        onPressed: onPressed,
        splashRadius: 20,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        cuotas.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 10 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(int index, double height) {
    if (json2.isEmpty || index >= json2.length) {
      return const Center(child: Text('No hay datos disponibles'));
    }
    final hasAtraso = json2[index]['fcCuotasEnAtraso'] != '' &&
        json2[index]['fitotal_debe'] != 0.0;
    final currencySymbol = json2[index]['fiIDMoneda'] == 2 ? '\$' : 'L';
    final currencyFormat = NumberFormat.currency(
        locale: 'en', symbol: currencySymbol, decimalDigits: 2);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          hasAtraso
              ? 'Cuota a Pagar Servicio #${json2[index]["fcIDPrestamo"]}'
              : 'Cuota Mensual Servicio #${json2[index]["fcIDPrestamo"]}',
          style: TextStyle(
              color: Colors.white,
              fontSize: height / 50,
              fontFamily: 'Gilroy Medium'),
        ),
        Text(
          hasAtraso
              ? currencyFormat.format(json2[index]['fitotal_debe'])
              : currencyFormat.format(cuotas[index]),
          style: TextStyle(
              color: Colors.white,
              fontSize: height / 35,
              fontFamily: 'Gilroy Bold'),
        ),
        if (hasAtraso)
          Text(
            '${json2[index]['fcCuotasEnAtraso']}',
            style: TextStyle(
                color: Colors.white,
                fontSize: height / 60,
                fontFamily: 'Gilroy Medium'),
          )
        else if (json2[index]['fdFechaProximoPago'] != null)
          Text(
            'Próximo Pago: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(json2[index]['fdFechaProximoPago']))}',
            style: TextStyle(
                color: Colors.white,
                fontSize: height / 60,
                fontFamily: 'Gilroy Medium'),
          ),
        SizedBox(height: height / 80),
      ],
    );
  }

  Widget _buildIconButtons(double height, double width) => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / 38),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: notifire.getwhite,
              boxShadow: [
                BoxShadow(
                  color: notifire.getdarkscolor.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 0.75),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.fbprincipal)
                  _buildIconButton(
                    "images/referir.png",
                    CustomStrings.referir,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const referidos_Screen()),
                    ),
                    height,
                    width,
                  ),
                _buildIconButton(
                  "images/high-speed.png",
                  'Test',
                  () => _navigateOrShowToast(const WebviewTest_screen()),
                  height,
                  width,
                ),
                _buildIconButton(
                  "images/apoyo.png",
                  'Comunícate',
                  () => _showWPDialog(context),
                  height,
                  width,
                ),
                _buildIconButton(
                  "images/caja.png",
                  CustomStrings.addservice,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddServices_Screen(
                        'Servicios',
                        fbprincipal: widget.fbprincipal,
                      ),
                    ),
                  ),
                  height,
                  width,
                ),
                _buildIconButton(
                  "images/pagar.png",
                  CustomStrings.pay,
                  () => _handlePayment(),
                  height,
                  width,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildIconButton(String imagePath, String label, VoidCallback onTap,
          double height, double width) =>
      Flexible(
        child: Column(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                height: height / 15,
                width: width / 7,
                decoration: BoxDecoration(
                  color: notifire.getprimerycolor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: Offset(0, 0.5),
                        spreadRadius: 0.12)
                  ],
                ),
                child: Center(
                    child: Image.asset(imagePath,
                        color: const Color(0xFFfaa61a), height: height / 20)),
              ),
            ),
            SizedBox(height: height / 60),
            Text(label,
                style: TextStyle(
                    fontFamily: "Gilroy Bold",
                    color: notifire.getdarkscolor,
                    fontSize: height / 80)),
          ],
        ),
      );

  Widget _buildServiceSection(double height, double width) => Padding(
        padding: EdgeInsets.symmetric(horizontal: width / 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height / 30),
            Text(CustomStrings.service,
                style: TextStyle(
                    fontFamily: "Gilroy Bold",
                    color: notifire.getdarkscolor,
                    fontSize: height / 40)),
            SizedBox(height: height / 50),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: json2.length,
              itemBuilder: (_, index) =>
                  _buildServiceCard(index, height, width),
            ),
            SizedBox(height: height / 80),
          ],
        ),
      );

  Widget _buildServiceCard(int index, double height, double width) {
    List detalles;
    try {
      detalles = json.decode(json2[index]["Detalles"]) as List<dynamic>;
    } catch (e) {
      detalles = [];
      debugPrint('Error decoding Detalles: $e');
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.01,
        vertical: height * 0.01,
      ),
      child: Card(
        key: ValueKey(index),
        color: notifire.getbackcolor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.grey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
          tilePadding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 8),
          childrenPadding: EdgeInsets.all(width * 0.04),
          backgroundColor: notifire.getbackcolor.withOpacity(0.95),
          collapsedBackgroundColor: notifire.getbackcolor,
          iconColor: notifire.getdarkscolor,
          collapsedIconColor: notifire.getorangeprimerycolor,
          collapsedTextColor: notifire.getorangeprimerycolor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildServiceTitle(index, height, width)),
            ],
          ),
          children: [
            _buildServiceDetails(index, width),
            Divider(color: Colors.grey.withOpacity(0.3), height: 1),
            _buildProductosSection(detalles, height, width),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTitle(int index, double height, double width) => Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.005),
        child: Row(
          children: [
            Container(
              height: height * 0.07,
              width: height * 0.07,
              decoration: BoxDecoration(
                color: notifire.getprimerycolor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.wifi,
                  color: notifire.getdarkscolor, size: height * 0.035),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${json2[index]["fcBarrio"].toString().capitalizeFirst!} #${json2[index]["fcIDPrestamo"]}",
                    style: TextStyle(
                      fontFamily: "Gilroy Bold",
                      color: notifire.getdarkscolor,
                      fontSize: height * 0.018,
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    'Fecha Inicio Servicio: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(json2[index]["fdFechaCreacionSolicitud"]))}',
                    style: TextStyle(
                      fontFamily: "Gilroy Medium",
                      color: notifire.getdarkscolor.withOpacity(0.7),
                      fontSize: height * 0.014,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: width * 0.02),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: json2[index]["fiEstadoServicio"] == 1
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    json2[index]["fiEstadoServicio"] == 1 ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      fontFamily: "Gilroy Bold",
                      color: json2[index]["fiEstadoServicio"] == 1
                          ? Colors.green
                          : Colors.red,
                      fontSize: height * 0.016,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.005),
                GestureDetector(
                  onTap: () => _openGoogleMaps(json2[index]["fcGeolocalizacion"]),
                  child: Container(
                    width: height * 0.065,
                    height: height * 0.045,
                    decoration: BoxDecoration(
                      color: notifire.getorangeprimerycolor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildServiceDetails(int index, double width) => Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                "Plazo Seleccionado", json2[index]["fiPlazoSeleccionado"].toString()),
            const SizedBox(height: 10),
            _buildDetailRow(
                "Departamento", json2[index]["fcDepartamento"].toString()),
            const SizedBox(height: 10),
            _buildDetailRow("Municipio", json2[index]["fcMunicipio"].toString()),
            const SizedBox(height: 10),
            _buildDetailRow("Barrio", json2[index]["fcBarrio"].toString()),
            const SizedBox(height: 10),
            _buildDetailRow("Dirección Exacta",
                json2[index]["fcDireccionDetallada"].toString().toUpperCase()),
          ],
        ),
      );

  Widget _buildDetailRow(String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildDetailText(label)),
          Expanded(child: _buildDetailText(value)),
        ],
      );

  Widget _buildDetailText(String text) => Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
        child: Text(text,
            style: TextStyle(
                fontFamily: "Gilroy Medium",
                color: notifire.getdarkscolor.withOpacity(0.6),
                fontSize: MediaQuery.of(context).size.height * 0.013)),
      );

  Widget _buildProductosSection(List detalles, double height, double width) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.02),
            child: Text('Productos',
                style: TextStyle(
                    fontFamily: "Gilroy Medium",
                    color: notifire.getdarkscolor.withOpacity(0.6),
                    fontSize: height * 0.013)),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: (detalles.length / 2).ceil(),
            itemBuilder: (_, index) =>
                _buildProductoRow(detalles, index, height, width),
          ),
        ],
      );

  Widget _buildProductoRow(List detalles, int index, double height, double width) {
    final firstIndex = index * 2;
    final secondIndex = firstIndex + 1;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: height * 0.01, horizontal: width * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: _buildProductoItem(detalles[firstIndex]["fcProducto"] ?? '')),
          SizedBox(width: width * 0.02),
          Expanded(
              child: secondIndex < detalles.length
                  ? _buildProductoItem(detalles[secondIndex]["fcProducto"] ?? '')
                  : Container()),
        ],
      ),
    );
  }

  Widget _buildProductoItem(String producto) => Row(
        children: [
          Icon(Icons.arrow_forward_ios_rounded,
              color: notifire.getdarkscolor, size: 10),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Expanded(
            child: Text(
              producto,
              style: TextStyle(
                  fontFamily: "Gilroy Medium",
                  color: notifire.getdarkscolor.withOpacity(0.6),
                  fontSize: MediaQuery.of(context).size.height * 0.013,
                  letterSpacing: 1.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  Future<void> _showWPDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: notifire.getbackcolor,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWPButton('SOPORTE TÉCNICO', 'SOPORTE'),
                const SizedBox(height: 15),
                _buildWPButton('SOPORTE PAGOS', 'PAGOS'),
                const SizedBox(height: 15),
                _buildWPButton('CONTRATAR', 'CONTRATAR'),
                const SizedBox(height: 15),
                _buildCallButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWPButton(String label, String option) => GestureDetector(
        onTap: () => widget.fbprincipal
            ? _showWPDialogNumeroTexto(context, option)
            : _showWPDialogNumero(context, option),
        child: Container(
          height: 40,
          width: 180,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/wp.png', height: 20, width: 20),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Gilroy Bold',
                      fontSize: 16)),
            ],
          ),
        ),
      );

  Widget _buildCallButton() => GestureDetector(
        onTap: () => _makePhoneCall('+50425406682'), // Prefijo internacional agregado
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
              Icon(Icons.phone, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'LLAMAR',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Gilroy Bold',
                    fontSize: 16),
              ),
            ],
          ),
        ),
      );

  Future<void> _showWPDialogNumeroTexto(BuildContext context, String opcion) async {
    final textoController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => _buildTextDialog(
          textoController, opcion, 'Ingrese un comentario', () {
        if (textoController.text.isEmpty) {
          _showWarningToast('Necesita ingresar un comentario');
          return;
        }
        _launchUrl(opcion, textoController.text);
        Navigator.pop(context);
      }),
    );
  }

  Future<void> _showWPDialogNumero(BuildContext context, String opcion) async {
    final numeroController = TextEditingController();
    final textoController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => _buildNumberTextDialog(
          numeroController, textoController, opcion, () {
        final numero = numeroController.text;
        final texto = textoController.text;
        if (numero.isEmpty) {
          _showWarningToast('Ingrese un número de teléfono');
          return;
        }
        if (numero.length != 8) {
          _showWarningToast('Son necesarios 8 dígitos');
          return;
        }
        if (texto.isEmpty) {
          _showWarningToast('Necesita ingresar un comentario');
          return;
        }
        _launchUrlSecundario(opcion, numero, texto);
        Navigator.pop(context);
      }),
    );
  }

  Widget _buildTextDialog(TextEditingController controller, String opcion,
          String title, VoidCallback onConfirm) =>
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
              color: notifire.getbackcolor,
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'Gilroy Bold',
                      fontSize: 16)),
              const SizedBox(height: 15),
              SizedBox(
                height: 200,
                child: TextField(
                  controller: controller,
                  decoration: _inputDecoration('Comentario'),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: onConfirm,
                child: Custombutton.button(
                    notifire.getorangeprimerycolor, 'Confirmar', MediaQuery.of(context).size.width / 2),
              ),
            ],
          ),
        ),
      );

  Widget _buildNumberTextDialog(
          TextEditingController numeroController,
          TextEditingController textoController,
          String opcion,
          VoidCallback onConfirm) =>
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
              color: notifire.getbackcolor,
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Ingrese el número de teléfono al cual desea se le contacte',
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Gilroy Bold',
                      fontSize: 16)),
              const SizedBox(height: 15),
              TextField(
                controller: numeroController,
                maxLength: 8,
                decoration: _inputDecoration('Número de teléfono'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 200,
                child: TextField(
                  controller: textoController,
                  decoration: _inputDecoration('Comentario'),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: onConfirm,
                child: Custombutton.button(
                    notifire.getorangeprimerycolor, 'Confirmar', MediaQuery.of(context).size.width / 2),
              ),
            ],
          ),
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        hintText: hint,
      );

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      CherryToast.error(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'No se pudo abrir el marcador telefónico',
          style: TextStyle(color: notifire.getdarkscolor),
        ),
      ).show(context);
    }
  }

  Future<void> _launchUrl(String opcion, String comentario) async {
    final prefs = await SharedPreferences.getInstance();
    final fcNumeroTelefono = prefs.getString("fcTelefono") ?? '';
    final uri = Uri.parse('https://srv2.rob.chat/REST_API/Tickets/Nuevo/');
    final headers = {
      'key': '8cbea7517da189fdcd89ff68dac8e67c',
      'Content-Type': 'application/json'
    };
    final body = jsonEncode({
      'key': '8cbea7517da189fdcd89ff68dac8e67c',
      'grupo': opcion,
      'telefono': '504$fcNumeroTelefono',
      'texto':
          'Hola tu referencia es %Ticket%, dentro de un momento un agente te contactará.',
      'pushId': '15',
      'token': 'RC15',
      'variables': {'comentario': comentario},
    });

    _showLoadingDialog();
    try {
      final response = await http.post(uri, body: body, headers: headers);
      Navigator.of(context, rootNavigator: true).pop();
      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        CherryToast.error(
          backgroundColor: notifire.getbackcolor,
          title: Text(
            'Error al enviar el mensaje: ${response.statusCode}',
            style: TextStyle(color: notifire.getdarkscolor),
          ),
        ).show(context);
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      CherryToast.error(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'Error de conexión: $e',
          style: TextStyle(color: notifire.getdarkscolor),
        ),
      ).show(context);
      debugPrint('Error in _launchUrl: $e');
    }
  }

  Future<void> _launchUrlSecundario(
      String opcion, String numero, String comentario) async {
    final prefs = await SharedPreferences.getInstance();
    final fcIdentidad = prefs.getString("fcIdentidad") ?? '';
    final uri = Uri.parse('https://srv2.rob.chat/REST_API/Tickets/Nuevo/');
    final headers = {
      'key': '8cbea7517da189fdcd89ff68dac8e67c',
      'Content-Type': 'application/json'
    };
    final body = jsonEncode({
      'key': '8cbea7517da189fdcd89ff68dac8e67c',
      'grupo': opcion,
      'telefono': '504$numero',
      'pushId': '15',
      'token': 'RC15',
      'texto':
          'Hola tu referencia es %Ticket%, dentro de un momento un agente te contactará.',
      'variables': {
        'identidad': fcIdentidad,
        'nombre_completo': fcNombreUsuario,
        'comentario': comentario
      },
    });

    _showLoadingDialog();
    try {
      final response = await http.post(uri, body: body, headers: headers);
      Navigator.of(context, rootNavigator: true).pop();
      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        CherryToast.error(
          backgroundColor: notifire.getbackcolor,
          title: Text(
            'Error al enviar el mensaje: ${response.statusCode}',
            style: TextStyle(color: notifire.getdarkscolor),
          ),
        ).show(context);
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      CherryToast.error(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'Error de conexión: $e',
          style: TextStyle(color: notifire.getdarkscolor),
        ),
      ).show(context);
      debugPrint('Error in _launchUrlSecundario: $e');
    }
  }

  void _showLoadingDialog() => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
            child: CircularProgressIndicator(
                color: notifire.getorangeprimerycolor)),
      );

  void _showSuccessDialog() => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(children: const [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('¡Éxito!')
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                  'El ticket se generó correctamente. Nuestro equipo se pondrá en contacto contigo en breve.',
                  textAlign: TextAlign.center),
              SizedBox(height: 20),
              Icon(Icons.verified, color: Colors.green, size: 80),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: notifire.getorangeprimerycolor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text('OK',
                        style: TextStyle(fontSize: 16, color: Colors.white))),
              ),
            ),
          ],
        ),
      );

  void _showWarningToast(String message) => CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(message,
            style: TextStyle(color: notifire.getdarkscolor),
            textAlign: TextAlign.start),
        borderRadius: 5,
      ).show(context);

  void _navigateOrShowToast(Widget page) {
    if (fcLlaveUnica.isEmpty) {
      _showWarningToast('Aún no cuentas con esta opción');
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  void _handlePayment() {
    if (fcLlaveUnica.isEmpty) {
      _showWarningToast('Aún no cuentas con esta opción');
    } else {
      DialogPago(context, notifire, fcLlaveUnica);
    }
  }

  Future<void> _launchUrlManual(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      CherryToast.error(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'No se pudo abrir el enlace: $url',
          style: TextStyle(color: notifire.getdarkscolor),
        ),
      ).show(context);
    }
  }

  Future<void> _openGoogleMaps(String? geolocalizacion) async {
    if (geolocalizacion == null || geolocalizacion.isEmpty) {
      CherryToast.error(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'No hay geolocalización disponible',
          style: TextStyle(color: notifire.getdarkscolor),
        ),
      ).show(context);
      return;
    }

    final coords = geolocalizacion.split(',');
    if (coords.length != 2) {
      CherryToast.error(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'Formato de geolocalización inválido',
          style: TextStyle(color: notifire.getdarkscolor),
        ),
      ).show(context);
      return;
    }

    final lat = coords[0].trim();
    final lng = coords[1].trim();
    final googleMapsUri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } else {
      CherryToast.error(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'No se pudo abrir Google Maps',
          style: TextStyle(color: notifire.getdarkscolor),
        ),
      ).show(context);
    }
  }
}