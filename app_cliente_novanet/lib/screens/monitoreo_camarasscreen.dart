// ignore_for_file: camel_case_types, file_names, unused_field

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class CamarasWebView_screen extends StatefulWidget {
  const CamarasWebView_screen({Key? key}) : super(key: key);

  @override
  _CamarasWebView_screenState createState() => _CamarasWebView_screenState();
}

class _CamarasWebView_screenState extends State<CamarasWebView_screen> {
  late ColorNotifire notifire;
  late WebViewController _controller;

  String? _currentUrl;
  List<Map<String, dynamic>> _camaras = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isWebViewLoading = false;
  final GlobalKey webViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    // Inicializar el controlador sin cargar URL todavía
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isWebViewLoading = true;
            });
            debugPrint('Iniciando carga: $url');
          },
          onPageFinished: (url) {
            setState(() {
              _isWebViewLoading = false;
            });
            debugPrint('Página cargada: $url');
          },
          onWebResourceError: (error) {
            setState(() {
              _isWebViewLoading = false;
            });
            debugPrint('Error en WebView: ${error.description}');
          },
          
        ),
      )
      ..loadRequest(Uri.parse('about:blank')); // Cargar una página en blanco inicialmente

    _cargarCamaras();
  }

  Future<void> _cargarCamaras() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? fiIDUnico = prefs.getString("fiIDUnico");

      if (fiIDUnico == null || fiIDUnico.isEmpty) {
        setState(() {
          _errorMessage = "No se encontró el ID de usuario.";
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
          'https://api.novanetgroup.com/api/Novanet/Usuario/ListadoCamarasAccesoCliente?piIDUsuarioApp=$fiIDUnico',
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          
          if (data.isNotEmpty) {
            setState(() {
              _camaras = data.cast<Map<String, dynamic>>();
              _currentUrl = _camaras[0]['fcURLCamara'];
              _isLoading = false;
            });
            
            // Cargar la URL después de que el widget esté construido
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _currentUrl != null) {
                _controller.loadRequest(Uri.parse(_currentUrl!));
              }
            });
          } else {
            setState(() {
              _errorMessage = "No se encontraron cámaras.";
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _errorMessage = jsonResponse['message'] ?? "Error al cargar las cámaras.";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Error al conectar (${response.statusCode}).";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error de conexión: $e";
        _isLoading = false;
      });
    }
  }

  void _cambiarCamara(String urlCamara) {
    if (_currentUrl == urlCamara) return;

    setState(() {
      _currentUrl = urlCamara;
    });

    _controller.loadRequest(Uri.parse(urlCamara));
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title:  Text(
          'Monitoreo de Cámaras',
          style: TextStyle(
            fontSize: 20,
            color: notifire.getdarkscolor,
            fontFamily: 'Gilroy Bold',
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: notifire.getbackcolor,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.all(8),
            
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ),
      body: Container(
        color: notifire.getbackcolor, // Fondo oscuro para mejor contraste
        child: Column(
          children: [
            // Barra de selección de cámaras
            Container(
              height: 100,
              color: notifire.getgreycolor.withOpacity(0.1),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: notifire.getwhite),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _camaras.isEmpty
                          ? Center(
                              child: Text(
                                "No tienes cámaras asignadas.",
                                style: TextStyle(color: notifire.getwhite),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _camaras.length,
                              itemBuilder: (context, index) {
                                final camara = _camaras[index];
                                final bool isSelected = _currentUrl == camara['fcURLCamara'];

                                return GestureDetector(
                                  onTap: () => _cambiarCamara(camara['fcURLCamara']),
                                  child: Container(
                                    width: 140,
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? notifire.getorangeprimerycolor
                                          : notifire.getdarkgreycolor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? Colors.white : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        camara['fcNombreCamara'] ?? 'Cámara ${index + 1}',
                                        style: TextStyle(
                                          color: notifire.getwhite,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),

            // Área principal del WebView
            Expanded(
              child: Stack(
                children: [
                  // WebView
                  if (_currentUrl != null)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: WebViewWidget(        key: webViewKey,
controller: _controller),
                    ),
                  
                  // Mensaje cuando no hay URL seleccionada
                  if (_currentUrl == null && !_isLoading && _errorMessage == null)
                    Center(
                      child: Text(
                        "Selecciona una cámara",
                        style: TextStyle(color: notifire.getwhite, fontSize: 18),
                      ),
                    ),
                  
                  // Indicador de carga del WebView
                  if (_isWebViewLoading && _currentUrl != null)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  
                  // Mensaje de error si no se puede cargar
                  if (_errorMessage != null && _currentUrl != null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, color: notifire.getorangeprimerycolor, size: 50),
                            const SizedBox(height: 10),
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: notifire.getwhite),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () {
                                if (_currentUrl != null) {
                                  _controller.loadRequest(Uri.parse(_currentUrl!));
                                }
                              },
                              child: const Text('Reintentar'),
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
      ),
    );
  }
}