import 'dart:convert';
import 'dart:ui';
import 'package:cherry_toast/cherry_toast.dart';
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
  final String productoBuscado;
  const AddServices_Screen(this.title, {Key? key, required this.fbprincipal, required this.productoBuscado}) : super(key: key);

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
  late List _originalDetallesNoAdd;
  bool visbleForm = false;
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  static const int _itemsPerPage = 5;
  final ScrollController _scrollController = ScrollController();
  bool mostrandoCarrito = false;
    final FocusNode _searchFocus = FocusNode();

  late double height;
  late double width;

  @override
  void initState() {
    super.initState();
    _originalDetallesNoAdd = [];
    _fetchData();
    _buscarproductoAlAbrir();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.of(context);
    height = media.size.height;
    width = media.size.width;
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchProductosPropios(),
      _fetchProductosNoAdquiridos(),
      _fetchSolicitudesHechas(),
    ]);
  }

  Future<void> _buscarproductoAlAbrir() async {
    final query = widget.productoBuscado;
    if (query.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      _filterProducts(query);
      _searchController.text = query;
      setState(() {
        visbleForm = true;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
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
        final data = jsonDecode(response.body);
        setState(() {
          detallessinadquirir = data;
          _originalDetallesNoAdd = List.from(data);
        });
      } else {
        setState(() {
          detallessinadquirir = [];
          _originalDetallesNoAdd = [];
        });
      }
    } catch (e) {
      setState(() {
        detallessinadquirir = [];
        _originalDetallesNoAdd = [];
      });
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
          'fiCantidad': detalle['fiCantidad'] ?? 1,
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
          mostrandoCarrito = false;
        });
        await _fetchSolicitudesHechas();
        await _fetchProductosNoAdquiridos();
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
      'fcProducto': detalle['fcProducto'],
      'NombreArchivo': detalle['NombreArchivo'],
      'fcMarca': detalle['fcMarca'],
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
    final detalleOriginal = _originalDetallesNoAdd.firstWhere((d) => d['RowNum'] == id);
    setState(() {
      productosSolicitar.remove(detalle);
      solicitudes.removeWhere((d) => d['RowNum'] == id);
      if (!detallessinadquirir.any((d) => d['RowNum'] == id)) {
        detallessinadquirir.add(detalleOriginal);
      }
    });
  }

  void _filterProducts(String query) {
    setState(() {
      detallessinadquirir = query.isEmpty
          ? List.from(_originalDetallesNoAdd)
          : _originalDetallesNoAdd
              .where((d) => d['fcProducto'].toString().toLowerCase().contains(query.toLowerCase()))
              .toList();
      _currentPage = 0;
    });
  }

  int _getTotalPages() {
    return (detallessinadquirir.length / _itemsPerPage).ceil();
  }

  List<dynamic> _getCurrentPageItems() {
    final start = _currentPage * _itemsPerPage;
    final end = start + _itemsPerPage;
    return detallessinadquirir.sublist(
      start,
      end.clamp(0, detallessinadquirir.length),
    );
  }

  void _nextPage() {
    if (_currentPage < _getTotalPages() - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifire.getorangeprimerycolor,
        title: Text(widget.title, style: TextStyle(fontSize: height * 0.025, fontFamily: 'Gilroy Bold', color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: notifire.getwhite, size: height * 0.03),
          onPressed: () => Navigator.pop(context),
        ),
        actions: widget.fbprincipal
            ? [
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: Colors.white),
                      onPressed: () => setState(() => mostrandoCarrito = !mostrandoCarrito),
                    ),
                    if (productosSolicitar.isNotEmpty)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${productosSolicitar.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: width * 0.03),
              ]
            : null,
      ),
      backgroundColor: notifire.getprimerycolor,
      body:
      GestureDetector( 
        
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        } ,
        child:  Column(
        children: [
          // Sección de servicios propios
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tus Servicios',
                    style: TextStyle(
                      fontFamily: 'Gilroy Bold',
                      fontSize: height * 0.028,
                      color: notifire.getdarkscolor,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  _buildProductosPropiosSection(),
                  
                  SizedBox(height: height * 0.04),
                  
                  // Sección de productos sugeridos
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: visbleForm ? _buildProductosNoAdquiridosSection() : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          
          // Sección del carrito (similar al modal anterior)
          if (mostrandoCarrito) _buildCarritoSection(),
        ],
      ),
      ),
      floatingActionButton: widget.fbprincipal
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                
                SizedBox(height: height * 0.01),
                FloatingActionButton.extended(
                  onPressed: () async {
                    setState(() => visbleForm = !visbleForm);
                    await Future.delayed(const Duration(milliseconds: 300));
                    if (visbleForm) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  icon: Icon(visbleForm ? Icons.close : Icons.add, color: Colors.white, size: height * 0.03),
                  label: Text(visbleForm ? 'Cerrar' : 'Agregar Productos', 
                           style: TextStyle(fontSize: height * 0.018, color: Colors.white)),
                  backgroundColor: visbleForm ? Colors.red : notifire.getorangeprimerycolor,
                ),
              ],
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildProductosPropiosSection() {
    return productosPropios.isEmpty
        ? Center(
            child: Text(
              'No hay servicios disponibles',
              style: TextStyle(
                color: notifire.getdarkscolor.withOpacity(0.6),
                fontSize: height * 0.02,
                fontFamily: 'Gilroy Medium',
              ),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: productosPropios.map<Widget>((producto) {
              final detalles = json.decode(producto["fcDetalles"]) as List<dynamic>;
              return Padding(
                padding: EdgeInsets.only(bottom: height * 0.015),
                child: Card(
                  color: notifire.getbackcolor,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.01),
                        leading: Container(
                          width: height * 0.06,
                          height: height * 0.06,
                          decoration: BoxDecoration(
                            color: notifire.getprimerycolor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.wifi, color: notifire.getdarkscolor, size: height * 0.03),
                        ),
                        title: Text(
                          'Servicio ${producto["fcBarrio"].toString().capitalize()} Sol.${producto["fiIDSolicitud"]} - ${producto["fcIDPrestamo"]}',
                          style: TextStyle(
                            fontFamily: 'Gilroy Medium',
                            fontSize: height * 0.018,
                            color: notifire.getdarkscolor,
                          ),
                          maxLines: null,
                          overflow: TextOverflow.visible,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.location_on, color: notifire.getorangeprimerycolor, size: height * 0.025),
                          onPressed: () => _openGoogleMaps(producto["fcGeolocalizacion"]),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.01),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: detalles.map<Widget>((item) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: height * 0.01),
                              child: Row(
                                children: [
                                  Icon(Icons.circle, color: notifire.getorangeprimerycolor, size: height * 0.015),
                                  SizedBox(width: width * 0.02),
                                  Expanded(
                                    child: Text(
                                      '${item['fcProducto']} (${item['fcMarca']}, ${item['TipoProducto']})',
                                      style: TextStyle(
                                        fontFamily: 'Gilroy Medium',
                                        fontSize: height * 0.015,
                                        color: notifire.getdarkscolor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.photo, color: notifire.getdarkscolor, size: height * 0.02),
                                    onPressed: () => _showImageDialog(item['NombreArchivo'], item['fcProducto']),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
  }

  Widget _buildProductosNoAdquiridosSection() {
  final totalPages = _getTotalPages();
  final currentItems = _getCurrentPageItems();

  return Column(
    children: [
      Text(
        'Productos Sugeridos',
        style: TextStyle(
          color: notifire.getdarkscolor,
          fontSize: height * 0.024,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: height * 0.02),

      // 🔍 Campo de búsqueda
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
      SizedBox(height: height * 0.02),

      // 🛒 Subtítulo con icono de carrito
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Flexible(
      child: Text(
        'Cuando tengas listos todos tus productos, presioná el icono del carrito para verlos o finalizar tu solicitud.',
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: height * 0.017,
          fontFamily: 'Gilroy Medium',
          color: notifire.getdarkscolor,
        ),
      ),
    ),
    SizedBox(width: width * 0.02),

    // 🔹 Carrito con contador (idéntico al del AppBar)
    Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.shopping_cart,
            color: notifire.getorangeprimerycolor,
            size: height * 0.035,
          ),
          tooltip: "Ver carrito",
          onPressed: () => setState(() => mostrandoCarrito = !mostrandoCarrito),
        ),
        if (productosSolicitar.isNotEmpty)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${productosSolicitar.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    ),
  ],
),

      SizedBox(height: height * 0.02),

      // 🔸 Lista de productos
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: currentItems.length,
        itemBuilder: (_, index) => _buildProductoCard(currentItems[index]),
      ),
      SizedBox(height: height * 0.02),

      // 🔸 Paginador
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: _currentPage > 0
                    ? notifire.getorangeprimerycolor
                    : notifire.getdarkgreycolor),
            onPressed: _currentPage > 0 ? _previousPage : null,
          ),
          SizedBox(width: width * 0.02),
          Text(
            'Página ${_currentPage + 1} de $totalPages',
            style: TextStyle(
              fontSize: height * 0.016,
              color: notifire.getdarkscolor,
            ),
          ),
          SizedBox(width: width * 0.02),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios,
                color: _currentPage < totalPages - 1
                    ? notifire.getorangeprimerycolor
                    : notifire.getdarkgreycolor),
            onPressed: _currentPage < totalPages - 1 ? _nextPage : null,
          ),
        ],
      ),
      

      SizedBox(height: height * 0.09),
    ],
  );
}

  Widget _buildProductoCard(dynamic detalle) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: height * 0.01),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: notifire.getbackcolor,
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.01),
        leading: GestureDetector(
          onTap: () => _showImageDialog(detalle['NombreArchivo'], detalle['fcProducto']),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              detalle['NombreArchivo'],
              width: height * 0.07,
              height: height * 0.07,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: height * 0.07,
                  height: height * 0.07,
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
                width: height * 0.07,
                height: height * 0.07,
                color: Colors.grey[300],
                child: Icon(Icons.broken_image, color: notifire.getdarkgreycolor),
              ),
            ),
          ),
        ),
        title: Text(
          detalle['fcProducto'].toString().toUpperCase(),
          style: TextStyle(
            color: notifire.getdarkscolor,
            fontWeight: FontWeight.bold,
            fontSize: height * 0.018,
          ),
        ),
        subtitle: Text(
          detalle['fcMarca'].toString(),
          style: TextStyle(color: notifire.getdarkgreycolor, fontSize: height * 0.015),
        ),
        trailing: IconButton(
          icon: Icon(Icons.add_circle, color: notifire.getorangeprimerycolor, size: height * 0.03),
          onPressed: () => _showConfirmationDialog(detalle['NombreArchivo'], detalle['fcProducto'], detalle['RowNum']),
        ),
      ),
    );
  }

  Widget _buildCarritoSection() {
    return Container(
      height: height * 0.7,
      decoration: BoxDecoration(
        color: notifire.getprimerycolor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Header del carrito
            Container(
              padding: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.04),
              decoration: BoxDecoration(
                color: notifire.getorangeprimerycolor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mis Solicitudes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: height * 0.022,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: height * 0.03),
                    onPressed: () => setState(() => mostrandoCarrito = false),
                  ),
                ],
              ),
            ),
            
            // Tabs
            Container(
              decoration: BoxDecoration(
                color: notifire.getorangeprimerycolor,
              ),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(icon: Icon(Icons.shopping_cart), text: 'Carrito Actual'),
                  Tab(icon: Icon(Icons.history), text: 'Solicitudes Hechas'),
                ],
              ),
            ),
            
            // Contenido de los tabs
            Expanded(
              child: TabBarView(
                children: [
                  _buildCarritoActual(),
                  _buildHistorialSolicitudes(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarritoActual() {
    if (productosSolicitar.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: height * 0.1, color: notifire.getdarkgreycolor),
            SizedBox(height: height * 0.02),
            Text(
              'No hay productos en el carrito',
              style: TextStyle(
                color: notifire.getdarkscolor,
                fontSize: height * 0.02,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Lista de productos
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(width * 0.04),
            itemCount: productosSolicitar.length,
            itemBuilder: (_, index) {
              final item = productosSolicitar[index];
              return Card(
                color: notifire.getbackcolor,
                margin: EdgeInsets.symmetric(vertical: height * 0.008),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['NombreArchivo'],
                      width: height * 0.06,
                      height: height * 0.06,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: height * 0.06,
                        height: height * 0.06,
                        color: Colors.grey[300],
                        child: Icon(Icons.devices, color: notifire.getdarkgreycolor),
                      ),
                    ),
                  ),
                  title: Text(
                    item['fcProducto'] ?? 'Producto',
                    style: TextStyle(
                      color: notifire.getdarkscolor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    item['fcMarca'] ?? '',
                    style: TextStyle(color: notifire.getdarkgreycolor),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cant: ${item['fiCantidad'] ?? 1}',
                        style: TextStyle(color: notifire.getdarkscolor),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red, size: height * 0.025),
                        onPressed: () => _showRemoveDialog(item['NombreArchivo'], item['fcProducto'], item['fiIDAdicionProduto']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Botón de enviar solicitud
        Container(
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            color: notifire.getbackcolor,
            border: Border(top: BorderSide(color: notifire.getdarkgreycolor.withOpacity(0.3))),
          ),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.send, color: Colors.white),
            label: Text(
              'Enviar Solicitud (${productosSolicitar.length})',
              style: TextStyle(color: Colors.white, fontSize: height * 0.018),
            ),
            onPressed: _sendSolicitudNueva,
            style: ElevatedButton.styleFrom(
              backgroundColor: notifire.getorangeprimerycolor,
              minimumSize: Size(double.infinity, height * 0.06),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        SizedBox(height: height * 0.09),
      ],
    );
  }

  Widget _buildHistorialSolicitudes() {
    if (solicitudesHechas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: height * 0.1, color: notifire.getdarkgreycolor),
            SizedBox(height: height * 0.02),
            Text(
              'No hay solicitudes previas',
              style: TextStyle(
                color: notifire.getdarkscolor,
                fontSize: height * 0.02,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(width * 0.04),
      itemCount: solicitudesHechas.length,
      itemBuilder: (_, index) {
        final solicitud = solicitudesHechas[index];
        return Card(
          color: notifire.getbackcolor,
          margin: EdgeInsets.symmetric(vertical: height * 0.008),
          child: ListTile(
            leading: Container(
              width: height * 0.06,
              height: height * 0.06,
              decoration: BoxDecoration(
                color: notifire.getorangeprimerycolor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.receipt_long, color: notifire.getorangeprimerycolor),
            ),
            title: Text(
              'Solicitud #${solicitud['fiIDAdicionProduto']}',
              style: TextStyle(
                color: notifire.getdarkscolor,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(solicitud['fdFechadeSolicitud']))}',
              style: TextStyle(color: notifire.getdarkgreycolor),
            ),
            trailing: IconButton(
              icon: Icon(Icons.visibility, color: notifire.getorangeprimerycolor),
              onPressed: () => _fetchSolicitudDetalles(solicitud['fiIDAdicionProduto']),
            ),
          ),
        );
      },
    );
  }

  // ... (mantener los métodos restantes como _showImageDialog, _showConfirmationDialog, 
  // _showRemoveDialog, _openGoogleMaps, _showDetallesDialog, etc.)

  

  void _showConfirmationDialog(String img, String articulo, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: notifire.getprimerycolor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                img,
                width: width * 0.4,
                height: height * 0.2,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: width * 0.4,
                    height: height * 0.2,
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
                  width: width * 0.4,
                  height: height * 0.2,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, color: notifire.getdarkgreycolor),
                ),
              ),
            ),
            SizedBox(height: height * 0.02),
            Text(
              '¿Agregar "$articulo" a la solicitud?',
              style: TextStyle(
                color: notifire.getdarkscolor,
                fontFamily: 'Gilroy Bold',
                fontSize: height * 0.02,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.red,
                fontSize: height * 0.018,
                fontFamily: 'Gilroy Medium',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _addSolicitud(id, articulo);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: notifire.getorangeprimerycolor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Agregar',
              style: TextStyle(
                color: Colors.white,
                fontSize: height * 0.018,
                fontFamily: 'Gilroy Medium',
              ),
            ),
          ),
        ],
      ),
    );
  }

  
    

  


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

  
  
  void _showImageDialog(String img, String nombre) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                img,
                fit: BoxFit.contain,
                width: width * 0.8,
                height: height * 0.5,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: width * 0.8,
                    height: height * 0.5,
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
                  width: width * 0.8,
                  height: height * 0.5,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 50, color: notifire.getdarkgreycolor),
                ),
              ),
            ),
            Positioned(
              top: height * 0.02,
              left: width * 0.02,
              child: Container(
                padding: EdgeInsets.all(width * 0.02),
                color: Colors.black54,
                child: Text(
                  nombre,
                  style: TextStyle(color: Colors.white, fontSize: height * 0.018),
                ),
              ),
            ),
            Positioned(
              top: height * 0.02,
              right: width * 0.02,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: height * 0.03),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  void _showSolicitudesDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: height * 0.8,
          decoration: BoxDecoration(
            color: notifire.getprimerycolor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: height * 0.01),
                  decoration: BoxDecoration(
                    color: notifire.getorangeprimerycolor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.7),
                    indicatorColor: Colors.white,
                    tabs: const [
                      Tab(text: 'Solicitud Actual'),
                      Tab(text: 'Historial'),
                    ],
                  ),
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
              padding: EdgeInsets.all(width * 0.04),
              child: ElevatedButton(
                onPressed: _sendSolicitudNueva,
                style: ElevatedButton.styleFrom(
                  backgroundColor: notifire.getorangeprimerycolor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: height * 0.015),
                ),
                child: Text(
                  'Realizar Solicitud',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height * 0.018,
                    fontFamily: 'Gilroy Bold',
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                itemCount: solicitudes.length,
                itemBuilder: (_, index) => _buildSolicitudCard(solicitudes[index]),
              ),
            ),
          ],
        )
      : Center(
          child: Text(
            'No hay productos seleccionados',
            style: TextStyle(
              color: notifire.getdarkscolor,
              fontSize: height * 0.02,
              fontFamily: 'Gilroy Medium',
            ),
          ),
        );

  Widget _buildHistorialTab() => solicitudesHechas.isNotEmpty
      ? ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          itemCount: solicitudesHechas.length,
          itemBuilder: (_, index) => _buildHistorialCard(solicitudesHechas[index]),
        )
      : Center(
          child: Text(
            'No hay solicitudes disponibles',
            style: TextStyle(
              color: notifire.getdarkscolor,
              fontSize: height * 0.02,
              fontFamily: 'Gilroy Medium',
            ),
          ),
        );

  Widget _buildSolicitudCard(dynamic detalle) => Card(
    margin: EdgeInsets.symmetric(vertical: height * 0.01),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: notifire.getbackcolor,
    elevation: 2,
    child: ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.01),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          detalle['NombreArchivo'],
          width: height * 0.06,
          height: height * 0.06,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: height * 0.06,
              height: height * 0.06,
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
            width: height * 0.06,
            height: height * 0.06,
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, color: notifire.getdarkgreycolor),
          ),
        ),
      ),
      title: Text(
        detalle['fcProducto'].toString().toUpperCase(),
        style: TextStyle(
          color: notifire.getdarkscolor,
          fontWeight: FontWeight.bold,
          fontSize: height * 0.018,
        ),
      ),
      subtitle: Text(
        detalle['fcMarca'].toString(),
        style: TextStyle(color: notifire.getdarkgreycolor, fontSize: height * 0.015),
      ),
      trailing: IconButton(
        icon: Icon(Icons.remove_circle, color: notifire.getorangeprimerycolor, size: height * 0.025),
        onPressed: () => _showRemoveDialog(detalle['NombreArchivo'], detalle['fcProducto'], detalle['RowNum']),
      ),
    ),
  );

  Widget _buildHistorialCard(dynamic solicitud) => Card(
    margin: EdgeInsets.symmetric(vertical: height * 0.01),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: notifire.getbackcolor,
    elevation: 2,
    child: ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.01),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset('images/logos.png', width: height * 0.06, height: height * 0.06),
      ),
      title: Text(
        'Solicitud #${solicitud['fiIDAdicionProduto']}',
        style: TextStyle(
          color: notifire.getdarkscolor,
          fontWeight: FontWeight.bold,
          fontSize: height * 0.018,
        ),
      ),
      subtitle: Text(
        'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(solicitud['fdFechadeSolicitud']))}',
        style: TextStyle(color: notifire.getdarkgreycolor, fontSize: height * 0.015),
      ),
      trailing: IconButton(
        icon: Icon(Icons.info, color: notifire.getorangeprimerycolor, size: height * 0.025),
        onPressed: () => _fetchSolicitudDetalles(solicitud['fiIDAdicionProduto']),
      ),
    ),
  );

  void _showRemoveDialog(String img, String articulo, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: notifire.getprimerycolor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                img,
                width: width * 0.4,
                height: height * 0.2,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: width * 0.4,
                    height: height * 0.2,
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
                  width: width * 0.4,
                  height: height * 0.2,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, color: notifire.getdarkgreycolor),
                ),
              ),
            ),
            SizedBox(height: height * 0.02),
            Text(
              '¿Quitar "$articulo" de la solicitud?',
              style: TextStyle(
                color: notifire.getdarkscolor,
                fontFamily: 'Gilroy Bold',
                fontSize: height * 0.02,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.red,
                fontSize: height * 0.018,
                fontFamily: 'Gilroy Medium',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _removeSolicitud(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: notifire.getorangeprimerycolor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Quitar',
              style: TextStyle(
                color: Colors.white,
                fontSize: height * 0.018,
                fontFamily: 'Gilroy Medium',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetallesDialog(List<dynamic> detalles) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: height * 0.8,
          decoration: BoxDecoration(
            color: notifire.getprimerycolor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: height * 0.015, horizontal: width * 0.04),
                decoration: BoxDecoration(
                  color: notifire.getorangeprimerycolor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detalles Solicitud #${detalles[0]['fiIDAdicionProduto']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: height * 0.022,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: height * 0.03),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.04),
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
    margin: EdgeInsets.symmetric(vertical: height * 0.01),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: notifire.getbackcolor,
    elevation: 2,
    child: ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.01),
      leading: GestureDetector(
        onTap: () => _showImageDialog(detalle['NombreArchivo'], detalle['fcProducto']),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            detalle['NombreArchivo'],
            width: height * 0.06,
            height: height * 0.06,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: height * 0.06,
                height: height * 0.06,
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
              width: height * 0.06,
              height: height * 0.06,
              color: Colors.grey[300],
              child: Icon(Icons.broken_image, color: notifire.getdarkgreycolor),
            ),
          ),
        ),
      ),
      title: Text(
        detalle['fcProducto'].toString().toUpperCase(),
        style: TextStyle(
          color: notifire.getdarkscolor,
          fontWeight: FontWeight.bold,
          fontSize: height * 0.018,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(detalle['fcMarca'].toString(), style: TextStyle(color: notifire.getdarkgreycolor, fontSize: height * 0.015)),
          Text(detalle['fcTipoProducto'].toString(), style: TextStyle(color: notifire.getdarkgreycolor, fontSize: height * 0.015)),
          Text('Cantidad: ${detalle['fiCantidad']}', style: TextStyle(color: notifire.getdarkgreycolor, fontSize: height * 0.015)),
        ],
      ),
    ),
  );
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1).toLowerCase();
}