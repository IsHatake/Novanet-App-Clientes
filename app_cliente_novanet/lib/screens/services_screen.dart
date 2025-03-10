import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:app_cliente_novanet/utils/media.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api.dart';
import '../utils/colornotifire.dart';

class AddServices_Screen extends StatefulWidget {
  final String title;
  final bool fbprincipal;
  const AddServices_Screen(this.title, {Key? key, required this.fbprincipal}) : super(key: key);

  @override
  State<AddServices_Screen> createState() => _AddServices_ScreenState();
}

class _AddServices_ScreenState extends State<AddServices_Screen> {
  late ColorNotifire notifire;
  List productosPropios = [];
  List detallessinadquirir = [];
  List solicitudes = [];
  List productosSolicitar = [];
  List solicitudesHechas = [];
  late final List _originalDetallesNoAdd = List.from(detallessinadquirir);
  bool visbleForm = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchProductosPropios(),
      _fetchProductosNoAdquiridos(),
      _fetchSolicitudesHechas(),
    ]);
  }

  Future<void> _fetchProductosPropios() async {
    final prefs = await SharedPreferences.getInstance();
    final fiIDSolicitud = prefs.getString("fiIDCuentaFamiliar") ?? '';
    try {
      final response = await http.get(Uri.parse(
          '${apiUrl}Servicio/Productos_ListaPorCliente?piIDSolicitud=$fiIDSolicitud'));
      if (response.statusCode == 200) {
        setState(() => productosPropios = jsonDecode(response.body));
      } else {
        setState(() => productosPropios = []);
      }
    } catch (e) {
      setState(() => productosPropios = []);
      debugPrint('Error fetching productos propios: $e');
    }
  }

  Future<void> _fetchProductosNoAdquiridos() async {
    final prefs = await SharedPreferences.getInstance();
    final fiIDSolicitud = prefs.getString("fiIDCuentaFamiliar") ?? '';
    try {
      final response = await http.get(Uri.parse(
          '${apiUrl}Servicio/ProductosAsolicitud_ListaPorCliente?piIDSolicitud=$fiIDSolicitud'));
      if (response.statusCode == 200) {
        setState(() => detallessinadquirir = jsonDecode(response.body));
      } else {
        setState(() => detallessinadquirir = []);
      }
    } catch (e) {
      setState(() => detallessinadquirir = []);
      debugPrint('Error fetching productos no adquiridos: $e');
    }
  }

  Future<void> _fetchSolicitudesHechas() async {
    final prefs = await SharedPreferences.getInstance();
    final piIDSolicitud = prefs.getString("fiIDCuentaFamiliar") ?? '';
    try {
      final response = await http.get(Uri.parse(
          '${apiUrl}Servicio/Solicitudes_AdicionProducto_Listado?piIDSolicitud=$piIDSolicitud'));
      if (response.statusCode == 200) {
        setState(() => solicitudesHechas = jsonDecode(response.body));
      }
    } catch (e) {
      setState(() => solicitudesHechas = []);
      debugPrint('Error fetching solicitudes hechas: $e');
    }
  }

  Future<void> _fetchSolicitudDetalles(int piIDAdicionProducto) async {
    try {
      final response = await http.get(Uri.parse(
          '${apiUrl}Servicio/Solicitudes_AdicionProducto_Detalles?piIDAdicionProducto=$piIDAdicionProducto'));
      if (response.statusCode == 200) {
        _showDetallesDialog(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error fetching solicitud detalles: $e');
    }
  }

  Future<void> _sendSolicitudNueva() async {
    final prefs = await SharedPreferences.getInstance();
    final piIDSolicitud = prefs.getString("fiIDCuentaFamiliar");
    if (piIDSolicitud == null) return;

    final jsonDetalles = productosSolicitar.map((detalle) => {
          'fiIDAdicionProduto': detalle['fiIDAdicionProduto'],
          'fiIDProducto': detalle['fiIDProducto'],
          'fiCantidad': detalle['Cantidad'] ?? 1,
        }).toList();

    final payload = jsonEncode({
      'fiIDSolicitud': int.parse(piIDSolicitud),
      'jsondetalles': jsonDetalles,
    });

    try {
      final response = await http.post(
        Uri.parse('${apiUrl}Servicio/SolicitudesAdicionProducto_Insertar'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: payload,
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded["code"] == 200) {
        CherryToast.success(
          backgroundColor: notifire.getbackcolor,
          title: Text(decoded["message"], style: TextStyle(color: notifire.getdarkscolor)),
        ).show(context);
        setState(() {
          productosSolicitar.clear();
          solicitudes.clear();
        });
        await _fetchSolicitudesHechas();
        Future.delayed(const Duration(seconds: 3), () => Navigator.pop(context));
      } else {
        CherryToast.error(
          backgroundColor: notifire.getbackcolor,
          title: Text(decoded["message"], style: TextStyle(color: notifire.getdarkscolor)),
        ).show(context);
      }
    } catch (e) {
      debugPrint('Error sending solicitud: $e');
    }
  }

  void _addSolicitud(int id, String fiIDProducto) {
    final detalle = _originalDetallesNoAdd.firstWhere((d) => d['RowNum'] == id);
    final nuevoProducto = {
      'fiIDAdicionProduto': detalle['RowNum'],
      'fiIDProducto': detalle['fiIDProducto'],
      'fiCantidad': 1,
    };
    setState(() {
      productosSolicitar.add(nuevoProducto);
      solicitudes.add(detalle);
      detallessinadquirir.remove(detalle);
    });
  }

  void _removeSolicitud(int id) {
    final detalle = productosSolicitar.firstWhere((d) => d['fiIDAdicionProduto'] == id);
    final detalle2 = solicitudes.firstWhere((d) => d['RowNum'] == id);
    setState(() {
      productosSolicitar.remove(detalle);
      solicitudes.remove(detalle2);
    });
  }

  void _filterProducts(String query) {
    setState(() {
      detallessinadquirir = query.isEmpty
          ? List.from(_originalDetallesNoAdd)
          : _originalDetallesNoAdd
              .where((d) => d['fcProducto'].toString().toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifire.getorangeprimerycolor,
        title: Text(widget.title, style: const TextStyle(fontSize: 20, fontFamily: 'Gilroy Bold', color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: notifire.getwhite),
          onPressed: () => Navigator.pop(context),
        ),
        actions: widget.fbprincipal
            ? [
                IconButton(
                  icon: Icon(Icons.assignment, color: notifire.getwhite, size: height * 0.04),
                  onPressed: _showSolicitudesDialog,
                ),
                const SizedBox(width: 15),
              ]
            : null,
      ),
      backgroundColor: notifire.getprimerycolor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductosPropiosSection(),
              const SizedBox(height: 30),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: visbleForm ? _buildProductosNoAdquiridosSection() : const SizedBox.shrink(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.fbprincipal
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => visbleForm = !visbleForm),
              icon: Icon(visbleForm ? Icons.close : Icons.add, color: Colors.white),
              label: Text(visbleForm ? 'Cerrar' : 'Agregar Productos', style: const TextStyle(color: Colors.white)),
              backgroundColor: visbleForm ? Colors.red : Colors.green,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildProductosPropiosSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: productosPropios.map((producto) {
      final detalles = json.decode(producto["fcDetalles"]);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Servicio ${producto["fcBarrio"].toString().capitalize()} #${producto["fcIDPrestamo"]}',
                      style: TextStyle(
                        color: notifire.getdarkscolor,
                        fontSize: height / 50,
                        fontFamily: 'Gilroy Medium',
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.location_on, color: notifire.getorangeprimerycolor),
                  onPressed: () => _openGoogleMaps(producto["fcGeolocalizacion"]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: [
                  DataColumn(
                    label: Text(
                      '#',
                      style: TextStyle(fontSize: 15, color: notifire.getdarkscolor),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Imagen',
                      style: TextStyle(fontSize: 15, color: notifire.getdarkscolor),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Artículo',
                      style: TextStyle(fontSize: 15, color: notifire.getdarkscolor),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Marca',
                      style: TextStyle(fontSize: 15, color: notifire.getdarkscolor),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Tipo',
                      style: TextStyle(fontSize: 15, color: notifire.getdarkscolor),
                    ),
                  ),
                ],
                rows: detalles.map<DataRow>((item) => DataRow(
                  color: MaterialStateProperty.resolveWith(
                      (states) => detalles.indexOf(item) % 2 == 0 ? notifire.gettableclaro : notifire.gettableoscuro),
                  cells: [
                    DataCell(Text(item['RowNum'].toString(), style: TextStyle(fontFamily: "Gilroy Medium", color: notifire.getdarkscolor))),
                    DataCell(IconButton(
                      icon: Icon(Icons.photo, color: notifire.getdarkscolor),
                      onPressed: () => _showImageDialog(item['NombreArchivo'], item['fcProducto']),
                    )),
                    DataCell(Text(item['fcProducto'].toString(), style: TextStyle(fontFamily: "Gilroy Medium", color: notifire.getdarkscolor))),
                    DataCell(Text(item['fcMarca'].toString(), style: TextStyle(fontFamily: "Gilroy Medium", color: notifire.getdarkscolor))),
                    DataCell(Text(item['TipoProducto'].toString(), style: TextStyle(fontFamily: "Gilroy Medium", color: notifire.getdarkscolor))),
                  ],
                )).toList(),
              ),
            ),
            Divider(color: notifire.getdarkscolor),
          ],
        ),
      );
    }).toList(),
  );

Future<void> _openGoogleMaps(String geolocalizacion) async {
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

    // Assuming fcGeolocalizacion is in "lat,lng" format
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
    final googleMapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await launchUrl(googleMapsUri)) {
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
  
  Widget _buildProductosNoAdquiridosSection() => Column(
    children: [
      Text(
        'Productos Sugeridos',
        style: TextStyle(
          color: notifire.getdarkscolor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 15),
      TextField(
        controller: _searchController,
        onChanged: _filterProducts,
        style: TextStyle(color: notifire.getdarkscolor),
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          hintStyle: TextStyle(color: notifire.getdarkgreycolor),
          filled: true,
          fillColor: notifire.getbackcolor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.search, color: notifire.getdarkgreycolor),
        ),
      ),
      const SizedBox(height: 15),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: detallessinadquirir.length,
        itemBuilder: (_, index) => _buildProductoCard(detallessinadquirir[index]),
      ),
    ],
  );

  Widget _buildProductoCard(dynamic detalle) => Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: notifire.getbackcolor,
    elevation: 2,
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: GestureDetector(
        onTap: () => _showImageDialog(detalle['NombreArchivo'], detalle['fcProducto']),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            detalle['NombreArchivo'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                    color: notifire.getorangeprimerycolor,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: Icon(Icons.broken_image, color: notifire.getdarkgreycolor),
            ),
          ),
        ),
      ),
      title: Text(
        detalle['fcProducto'].toString().toUpperCase(),
        style: TextStyle(color: notifire.getdarkscolor, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(detalle['fcMarca'].toString(), style: TextStyle(color: notifire.getdarkgreycolor)),
      trailing: IconButton(
        icon: Icon(Icons.add_circle, color: notifire.getorangeprimerycolor),
        onPressed: () => _showConfirmationDialog(detalle['NombreArchivo'], detalle['fcProducto'], detalle['RowNum']),
      ),
    ),
  );

  void _showImageDialog(String img, String nombre) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                img,
                fit: BoxFit.contain,
                width: 300,
                height: 300,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: notifire.getorangeprimerycolor,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 300,
                  height: 300,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 50, color: notifire.getdarkgreycolor),
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black54,
                child: Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(String img, String articulo, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: notifire.getprimerycolor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                img,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: notifire.getorangeprimerycolor,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, color: notifire.getdarkgreycolor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¿Agregar "$articulo" a la solicitud?',
              style: TextStyle(color: notifire.getdarkscolor, fontFamily: 'Gilroy Bold', fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              _addSolicitud(id, articulo);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: notifire.getorangeprimerycolor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSolicitudesDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: height * 0.8,
          decoration: BoxDecoration(
            color: notifire.getprimerycolor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: notifire.getdarkscolor,
                  indicatorColor: notifire.getorangeprimerycolor,
                  tabs: const [Tab(text: 'Solicitud Actual'), Tab(text: 'Historial')],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildSolicitudActualTab(),
                      _buildHistorialTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSolicitudActualTab() => solicitudes.isNotEmpty
      ? Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _sendSolicitudNueva,
                style: ElevatedButton.styleFrom(
                  backgroundColor: notifire.getorangeprimerycolor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Realizar Solicitud', style: TextStyle(color: Colors.white)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: solicitudes.length,
                itemBuilder: (_, index) => _buildSolicitudCard(solicitudes[index]),
              ),
            ),
          ],
        )
      : Center(child: Text('No hay productos seleccionados', style: TextStyle(color: notifire.getdarkscolor)));

  Widget _buildHistorialTab() => solicitudesHechas.isNotEmpty
      ? ListView.builder(
          itemCount: solicitudesHechas.length,
          itemBuilder: (_, index) => _buildHistorialCard(solicitudesHechas[index]),
        )
      : Center(child: Text('No hay solicitudes disponibles', style: TextStyle(color: notifire.getdarkscolor)));

  Widget _buildSolicitudCard(dynamic detalle) => Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: notifire.getbackcolor,
    child: ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          detalle['NombreArchivo'],
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 50,
              height: 50,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                  color: notifire.getorangeprimerycolor,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            width: 50,
            height: 50,
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, color: notifire.getdarkgreycolor),
          ),
        ),
      ),
      title: Text(
        detalle['fcProducto'].toString().toUpperCase(),
        style: TextStyle(color: notifire.getdarkscolor, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(detalle['fcMarca'].toString(), style: TextStyle(color: notifire.getdarkgreycolor)),
      trailing: IconButton(
        icon: Icon(Icons.remove_circle, color: notifire.getorangeprimerycolor),
        onPressed: () => _showRemoveDialog(detalle['NombreArchivo'], detalle['fcProducto'], detalle['RowNum']),
      ),
    ),
  );

  Widget _buildHistorialCard(dynamic solicitud) => Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: notifire.getbackcolor,
    child: ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset('images/logos.png', width: 50, height: 50),
      ),
      title: Text(
        'Solicitud #${solicitud['fiIDAdicionProduto']}',
        style: TextStyle(color: notifire.getdarkscolor, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(solicitud['fdFechadeSolicitud']))}',
        style: TextStyle(color: notifire.getdarkgreycolor),
      ),
      trailing: IconButton(
        icon: Icon(Icons.info, color: notifire.getorangeprimerycolor),
        onPressed: () => _fetchSolicitudDetalles(solicitud['fiIDAdicionProduto']),
      ),
    ),
  );

  void _showRemoveDialog(String img, String articulo, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: notifire.getprimerycolor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                img,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: notifire.getorangeprimerycolor,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, color: notifire.getdarkgreycolor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¿Quitar "$articulo" de la solicitud?',
              style: TextStyle(color: notifire.getdarkscolor, fontFamily: 'Gilroy Bold', fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              _removeSolicitud(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: notifire.getorangeprimerycolor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Quitar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDetallesDialog(List<dynamic> detalles) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: height * 0.8,
          decoration: BoxDecoration(
            color: notifire.getprimerycolor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: notifire.getorangeprimerycolor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detalles Solicitud #${detalles[0]['fiIDAdicionProduto']}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: detalles.length,
                  itemBuilder: (_, index) => _buildDetalleCard(detalles[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetalleCard(dynamic detalle) => Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: notifire.getbackcolor,
    child: ListTile(
      leading: GestureDetector(
        onTap: () => _showImageDialog(detalle['NombreArchivo'], detalle['fcProducto']),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            detalle['NombreArchivo'],
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 50,
                height: 50,
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                    color: notifire.getorangeprimerycolor,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 50,
              color: Colors.grey[300],
              child: Icon(Icons.broken_image, color: notifire.getdarkgreycolor),
            ),
          ),
        ),
      ),
      title: Text(
        detalle['fcProducto'].toString().toUpperCase(),
        style: TextStyle(color: notifire.getdarkscolor, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(detalle['fcMarca'].toString(), style: TextStyle(color: notifire.getdarkgreycolor)),
          Text(detalle['fcTipoProducto'].toString(), style: TextStyle(color: notifire.getdarkgreycolor)),
          Text('Cantidad: ${detalle['fiCantidad']}', style: TextStyle(color: notifire.getdarkgreycolor)),
        ],
      ),
    ),
  );
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1).toLowerCase();
}