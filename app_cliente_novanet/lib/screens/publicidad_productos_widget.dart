import 'dart:convert';
import 'package:app_cliente_novanet/api.dart';
import 'package:app_cliente_novanet/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'services_screen.dart';

class AdItem {
  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const AdItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

class PublicidadProductosWidget extends StatefulWidget {
  final double cardSize;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final bool showTitles;
  final Color? titleColor; // 🔹 para integrarse con tu tema
  final String title; // 🔹 título configurable

  const PublicidadProductosWidget({
    Key? key,
    this.cardSize = 110.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.spacing = 8.0,
    this.showTitles = true,
    this.titleColor,
    this.title = "Cosas que te pueden interesar",
  }) : super(key: key);

  @override
  State<PublicidadProductosWidget> createState() =>
      _PublicidadProductosWidgetState();
}

class _PublicidadProductosWidgetState
    extends State<PublicidadProductosWidget> {
  List<AdItem> _productos = [];
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchProductosPublicitarios();
  }

  /// 🔄 Carga los productos destacados del backend
  Future<void> _fetchProductosPublicitarios() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final fiIDSolicitud = prefs.getString("fiIDCuentaFamiliar") ?? '';

      final response = await http.get(Uri.parse(
          '${apiUrl}Servicio/ProductosAsolicitud_ListaPorCliente?piIDSolicitud=$fiIDSolicitud'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final filtrados = data
            .where((item) => item['fbPrioridadVisualizacion'] == true)
            .map((item) => AdItem(
                  imageUrl: item["NombreArchivo"] ?? "",
                  title: item["fcProducto"]  ?? "Sin nombre",
                  subtitle: '',
                  onTap: () => {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddServices_Screen(
                        'Servicios',
                        fbprincipal: true,
                        productoBuscado: item["fcProducto"] ?? "",
                      ),
                    ),
                  )
                  },
                ))
            .toList();

        setState(() {
          _productos = filtrados;
        });
      } else {
        _hasError = true;
      }
    } catch (e) {
      debugPrint('Error cargando productos publicitarios: $e');
      _hasError = true;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Espacio arriba del título
          SizedBox(height: height / 30),

          // 🔹 Título de la sección
          Text(
            widget.title,
            style: TextStyle(
              fontFamily: "Gilroy Bold",
              color: widget.titleColor ?? Colors.black87,
              fontSize:height / 40,
            ),
          ),

          // 🔹 Espacio debajo del título
          SizedBox(height: height / 50),

          // 🔹 Cuerpo del carrusel
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildBody(),
          ),

          // 🔹 Espacio debajo del carrusel
          SizedBox(height: height / 30),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const SizedBox(
        height: 110,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return _ErrorOrEmptyState(
        message: "Error al cargar productos destacados.",
        onRetry: _fetchProductosPublicitarios,
      );
    }

    if (_productos.isEmpty) {
      return _ErrorOrEmptyState(
        message: "No hay productos destacados para mostrar.",
        onRetry: _fetchProductosPublicitarios,
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchProductosPublicitarios,
      displacement: 20,
      child: SizedBox(
        height: widget.cardSize,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: widget.padding,
          scrollDirection: Axis.horizontal,
          itemCount: _productos.length,
          separatorBuilder: (_, __) => SizedBox(width: widget.spacing),
          itemBuilder: (context, index) {
            final item = _productos[index];
            return _AdCard(
              item: item,
              size: widget.cardSize,
              showTitles: widget.showTitles,
            );
          },
        ),
      ),
    );
  }
}

/// 🧩 Tarjeta individual
class _AdCard extends StatelessWidget {
  final AdItem item;
  final double size;
  final bool showTitles;

  const _AdCard({
    Key? key,
    required this.item,
    required this.size,
    required this.showTitles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap ??
          () {
          
            
          },
      child: SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      ),
                    ),
                  );
                },
              ),
              if (showTitles) ...[
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black54],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

/// 🧠 Estado vacío o error con botón de recarga
class _ErrorOrEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorOrEmptyState({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Recargar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(fontSize: 13),
              ),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
