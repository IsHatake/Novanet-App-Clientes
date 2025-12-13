import 'dart:convert';

import 'package:app_cliente_novanet/utils/button.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:app_cliente_novanet/api.dart';

class DepositoModel {
  String pcIdentidad;
  String pcNombreCliente;
  String pcTelefonoCliente;
  double pnValordelDeposito;
  File? pcArchivo;
  String pcComentarioCliente;
  String pcIP;
  String? pcNombreArchivo;

  DepositoModel({
    required this.pcIdentidad,
    required this.pcNombreCliente,
    required this.pcTelefonoCliente,
    required this.pnValordelDeposito,
    required this.pcArchivo,
    required this.pcComentarioCliente,
    required this.pcIP,
    this.pcNombreArchivo,
  });

  Map<String, dynamic> toJson() {
    return {
      'pcIdentidad': pcIdentidad,
      'pcNombreCliente': pcNombreCliente,
      'pcTelefonoCliente': pcTelefonoCliente,
      'pnValordelDeposito': pnValordelDeposito,
      'pcArchivo': pcArchivo,
      'pcComentarioCliente': pcComentarioCliente,
      'pcIP': pcIP,
      'pcNombreArchivo': pcNombreArchivo,
    };
  }
}

class RegistroDepositoScreen extends StatefulWidget {
  final dynamic notifire;

  const RegistroDepositoScreen({Key? key, required this.notifire})
      : super(key: key);

  @override
  _RegistroDepositoScreenState createState() => _RegistroDepositoScreenState();
}

class _RegistroDepositoScreenState extends State<RegistroDepositoScreen> {
  File? _image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _identidadController = TextEditingController();
  final _nombreClienteController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _comentarioController = TextEditingController();
  bool identidad = true;
  String pcIP = '';
  String? pcNombreArchivo;

  // Variables para selección manual
  List<TextLine> _detectedTextLines = [];
  bool _showManualSelection = false;
  String? _selectedMontoText;

  @override
  void initState() {
    super.initState();
    setDatos();
    _getIPAddress().then((ip) {
      setState(() {
        pcIP = ip;
      });
    });
  }

  Future<String> _getIPAddress() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ip'];
      } else {
        throw Exception('Failed to get IP address');
      }
    } catch (e) {
      throw Exception('Failed to get IP address: $e');
    }
  }

  Future<void> sendDatos() async {
    try {
      final Uri url = Uri.parse('${apiUrl}Servicio/SubirComprobanteDeposito');
      String diaHora = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
      String hora = '${DateTime.now().hour}-${DateTime.now().minute}';

      DepositoModel model = DepositoModel(
        pcIdentidad: _identidadController.text,
        pcNombreCliente: _nombreClienteController.text,
        pcTelefonoCliente: _telefonoController.text,
        pnValordelDeposito: double.parse(_montoController.text.replaceAll(r',', '')),
        pcArchivo: _image,
        pcComentarioCliente: _comentarioController.text,
        pcIP: pcIP,
        pcNombreArchivo: '${diaHora}_${hora}_${_nombreClienteController.text}.${_image!.path.split('.').last}',
      );

      var modelJson = jsonEncode({
        ...model.toJson(),
        'pcArchivo': _image != null ? base64Encode(_image!.readAsBytesSync()) : null,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: modelJson,
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);

        CherryToast.success(
          backgroundColor: widget.notifire.getbackcolor,
          title: Text('Deposito subido correctamente',
              style: TextStyle(color: widget.notifire.getdarkscolor),
              textAlign: TextAlign.start),
          borderRadius: 5,
        ).show(context);
      } else {
        CherryToast.error(
          backgroundColor: widget.notifire.getbackcolor,
          title: Text('Ha ocurrido un error Inesperado',
              style: TextStyle(color: widget.notifire.getdarkscolor),
              textAlign: TextAlign.start),
          borderRadius: 5,
        ).show(context);
      }
    } catch (e) {
      CherryToast.error(
        backgroundColor: widget.notifire.getbackcolor,
        title: Text('Contactenos para mas Información',
            style: TextStyle(color: widget.notifire.getdarkscolor),
            textAlign: TextAlign.start),
        borderRadius: 5,
      ).show(context);
    }
  }

  Future<void> setDatos() async {
    final prefs = await SharedPreferences.getInstance();
    String? fcIdentidad = prefs.getString("fcIdentidad");
    String? fcNombreUsuario = prefs.getString("fcNombreUsuario");
    String? fcNumeroTelefono = prefs.getString("fcTelefono");

    _identidadController.text = fcIdentidad ?? '';
    _nombreClienteController.text = fcNombreUsuario ?? '';
    _telefonoController.text = fcNumeroTelefono ?? '';
    if (_identidadController.text.isNotEmpty) {
      setState(() {
        identidad = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _showManualSelection = false;
        _selectedMontoText = null;
      });
      await _extractTextFromImage();
    }
  }

  Future<void> _extractTextFromImage() async {
  if (_image == null) return;

  final inputImage = InputImage.fromFile(_image!);
  final textRecognizer = GoogleMlKit.vision.textRecognizer();

  try {
    final recognizedText = await textRecognizer.processImage(inputImage);

    // Guardar todas las líneas detectadas para selección manual
    _detectedTextLines.clear();
    for (TextBlock block in recognizedText.blocks) {
      _detectedTextLines.addAll(block.lines);
    }

    // Lista de candidatos a monto
    List<MontoCandidate> montoCandidates = [];

    // Palabras clave específicas para Lempiras
    final montoKeywords = [
      'monto', 'deposito', 'depositado', 'total', 'importe', 'valor',
      'cantidad', 'pago', 'transferencia', 'abono', 'depósito', 'lps',
      'hnl', 'lempiras', 'l.', 'monto total', 'total a pagar', 'valor del depósito'
    ];

    // SOLO patrones para Lempiras
    final lempiraPatterns = [
      // Formato Honduras: LPS 1,000.00 o L. 1,000.00
      RegExp(r'(?:LPS?|L\.?)\s*[\d,]+\.?\d{0,2}', caseSensitive: false),
      // Números con comas y puntos (asumimos que son Lempiras)
      RegExp(r'\b\d{1,3}(?:,\d{3})*(?:\.\d{2})?\b'),
      // Números grandes sin formato
      RegExp(r'\b\d{4,}\b'),
    ];

    String fullText = '';

    // Procesar todo el texto
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        fullText += '${line.text}\n';

        final text = line.text.toLowerCase().trim();

        // 1. Buscar con patrones de Lempiras
        for (var pattern in lempiraPatterns) {
          final matches = pattern.allMatches(line.text);
          for (var match in matches) {
            final rawNumber = match.group(0)!;
            final cleanNumber = _cleanMonetaryString(rawNumber);
            if (cleanNumber.isNotEmpty) {
              final value = double.tryParse(cleanNumber.replaceAll(',', ''));
              if (value != null && value > 0 && value <= 50000) {
                // Calcular confianza
                double confidence = 0.8;
                if (pattern == lempiraPatterns[0]) {
                  confidence = 0.95; // Alto para formatos con LPS/L.
                }

                montoCandidates.add(MontoCandidate(
                  value: value,
                  rawText: rawNumber,
                  confidence: confidence,
                  reason: 'formato_lempiras',
                  line: line,
                ));
              }
            }
          }
        }

        // 2. Buscar líneas con palabras clave
        for (String keyword in montoKeywords) {
          if (text.contains(keyword)) {
            // Buscar números en la misma línea
            _findNumbersInLine(line.text, montoCandidates, keyword, line);
          }
        }
      }
    }

    // 3. Buscar patrones contextuales específicos
    final contextualPatterns = [
      RegExp(r'(?:total|monto|importe)[:\s]+(?:LPS?|L\.?)?\s*([\d,]+\.?\d{0,2})', caseSensitive: false),
    ];

    for (var pattern in contextualPatterns) {
      final matches = pattern.allMatches(fullText);
      for (var match in matches) {
        if (match.groupCount >= 1) {
          final numberStr = match.group(1)!;
          final cleanNumber = _cleanMonetaryString(numberStr);
          final value = double.tryParse(cleanNumber.replaceAll(',', ''));

          if (value != null && value > 0) {
            montoCandidates.add(MontoCandidate(
              value: value,
              rawText: numberStr,
              confidence: 0.9,
              reason: 'patron_contextual',
              line: recognizedText.blocks.first.lines.first,
            ));
          }
        }
      }
    }

    // 4. Filtrar y ordenar candidatos
    if (montoCandidates.isEmpty) {
      _showManualMontoSelection();
      return;
    }

    // Eliminar duplicados
    montoCandidates = _removeDuplicateCandidates(montoCandidates);

    // Ordenar por confianza
    montoCandidates.sort((a, b) {
      int confidenceCompare = b.confidence.compareTo(a.confidence);
      if (confidenceCompare != 0) return confidenceCompare;
      return _calculateRealismScore(b.value).compareTo(_calculateRealismScore(a.value));
    });

    // Filtrar candidatos válidos
    final validCandidates = montoCandidates
        .where((c) => c.value <= 50000 && c.value >= 1)
        .toList();

    if (validCandidates.isEmpty) {
      _showManualMontoSelection();
      return;
    }

    // Mostrar selección si hay ambigüedad
    final highConfidenceCandidates = validCandidates.where((c) => c.confidence >= 0.8).toList();
    final hasAmbiguity = highConfidenceCandidates.length > 1 || validCandidates.length > 2;

    if (hasAmbiguity) {
      _showMultipleOptionsSelection(validCandidates);
      return;
    }

    // Usar el mejor candidato
    final bestCandidate = validCandidates.first;
    if (validCandidates.length > 1) {
      final secondCandidate = validCandidates[1];
      final confidenceGap = bestCandidate.confidence - secondCandidate.confidence;
      if (confidenceGap < 0.2) {
        _showMultipleOptionsSelection(validCandidates);
        return;
      }
    }

    // Caso ideal: un solo candidato claro
    final montoTexto = _formatMonetaryOutput(bestCandidate.value);
    setState(() {
      _montoController.text = montoTexto;
      _showManualSelection = false;
    });

    _showExtractionFeedback(bestCandidate, montoCandidates.length);

  } catch (e) {
    if (kDebugMode) {
      print("Error OCR: $e");
    }
    CherryToast.error(
      title: const Text('Error al procesar imagen'),
      backgroundColor: widget.notifire.getbackcolor,
    ).show(context);
  } finally {
    await textRecognizer.close();
  }
}

  // Función para buscar números en la misma línea
  void _findNumbersInLine(String lineText, List<MontoCandidate> candidates, String keyword, TextLine line) {
  // Buscar solo números puros o con formato Lempira
  final numberPatterns = [
    RegExp(r'(?:LPS?|L\.?)\s*[\d,]+\.?\d{0,2}', caseSensitive: false),
    RegExp(r'[\d,]+\.?\d{0,2}'),
  ];

  for (var pattern in numberPatterns) {
    final matches = pattern.allMatches(lineText);
    for (var match in matches) {
      final numStr = match.group(0)!;
      final cleanNum = _cleanMonetaryString(numStr);
      final numValue = double.tryParse(cleanNum.replaceAll(',', ''));

      if (numValue != null && numValue > 0) {
        // Calcular distancia al keyword
        final textLower = lineText.toLowerCase();
        final keywordIndex = textLower.indexOf(keyword);
        final numberIndex = textLower.indexOf(numStr);
        final distance = (keywordIndex - numberIndex).abs();

        double confidence = 0.7 / (1 + distance / 20);
        if (distance < 10) confidence = 0.85;

        // Aumentar confianza si es formato Lempira
        if (pattern == numberPatterns[0]) {
          confidence = 0.9;
        }

        candidates.add(MontoCandidate(
          value: numValue,
          rawText: numStr,
          confidence: confidence,
          reason: 'keyword_cercana: $keyword',
          line: line,
        ));
      }
    }
  }
}
  // Eliminar candidatos duplicados (valores muy cercanos)
  List<MontoCandidate> _removeDuplicateCandidates(List<MontoCandidate> candidates) {
    List<MontoCandidate> uniqueCandidates = [];

    for (var candidate in candidates) {
      bool isDuplicate = uniqueCandidates.any((existing) =>
      (existing.value - candidate.value).abs() < 0.01 // Menos de 1 centavo de diferencia
      );

      if (!isDuplicate) {
        uniqueCandidates.add(candidate);
      }
    }

    return uniqueCandidates;
  }

  // Calcular score de realismo (montos más comunes en depósitos)
  double _calculateRealismScore(double value) {
    // Los depósitos típicos están en estos rangos
    if (value >= 100 && value <= 10000) return 1.0;
    if (value >= 50 && value <= 500) return 0.8;
    if (value >= 10 && value <= 49) return 0.6;
    if (value > 10000 && value <= 50000) return 0.7;
    return 0.3; // Montos muy pequeños o muy grandes son menos probables
  }

  String _cleanMonetaryString(String input) {
    // Limpiar cadena monetaria manteniendo el formato correcto
    String cleaned = input
        .replaceAll(RegExp(r'[^\d.,]'), '') // Mantener solo números, punto y coma
        .replaceAllMapped(RegExp(r'\.(\d{3})'), (m) => m[1]!) // .000 -> 000
        .replaceAllMapped(RegExp(r',(\d{3})'), (m) => m[1]!); // ,000 -> 000 (para formato europeo)

    // Si termina con .00 o ,00, mantener como está
    if (cleaned.endsWith('.00') || cleaned.endsWith(',00')) {
      return cleaned;
    }

    return cleaned;
  }

  String _formatMonetaryOutput(double value) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(value);
  }

  // Método auxiliar para obtener color según confianza
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  // Mostrar selección de múltiples opciones
 void _showMultipleOptionsSelection(List<MontoCandidate> candidates) {
  setState(() {
    _showManualSelection = true;
  });

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: widget.notifire.getbackcolor,
        title: Text(
          'Se detectaron múltiples montos',
          style: TextStyle(color: widget.notifire.getdarkscolor),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecciona el monto correcto (Lempiras):',
                style: TextStyle(
                  color: widget.notifire.getdarkscolor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    final candidate = candidates[index];
                    return Card(
                      color: widget.notifire.getprimerycolor,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          Icons.attach_money,
                          color: _getConfidenceColor(candidate.confidence),
                        ),
                        title: Text(
                          'L ${_formatMonetaryOutput(candidate.value)}',
                          style: TextStyle(
                            color: widget.notifire.getdarkscolor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Confianza: ${(candidate.confidence * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: widget.notifire.getdarkscolor.withOpacity(0.7),
                          ),
                        ),
                        trailing: candidate.confidence >= 0.8 
                            ? const Icon(Icons.star, color: Colors.amber)
                            : null,
                        onTap: () {
                          setState(() {
                            _montoController.text = _formatMonetaryOutput(candidate.value);
                            _showManualSelection = false;
                            _selectedMontoText = candidate.rawText;
                          });
                          Navigator.of(context).pop();
                          
                          CherryToast.success(
                            title: Text('Monto establecido: L ${_formatMonetaryOutput(candidate.value)}'),
                            backgroundColor: widget.notifire.getbackcolor,
                          ).show(context);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '¿No ves el monto correcto?',
                style: TextStyle(
                  color: widget.notifire.getdarkscolor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showManualMontoSelection();
            },
            child: Text(
              'Ver todas las opciones',
              style: TextStyle(color: widget.notifire.getorangeprimerycolor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showManualEntryOption();
            },
            child: const Text(
              'Ingresar manualmente',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}

  // Método auxiliar para construir tarjetas de texto
  Widget _buildTextLineCard(TextLine line, bool hasNumbers) {
    return Card(
      color: hasNumbers ? Colors.green[50] : widget.notifire.getprimerycolor,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        title: Text(
          line.text,
          style: TextStyle(
            color: widget.notifire.getdarkscolor,
            fontWeight: hasNumbers ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        subtitle: hasNumbers 
            ? const Text(
                'Contiene números - Toque para seleccionar',
                style: TextStyle(color: Colors.green, fontSize: 12),
              )
            : null,
        onTap: () {
          _processManualSelection(line.text);
          Navigator.of(context).pop();
        },
        trailing: hasNumbers 
            ? const Icon(Icons.attach_money, color: Colors.green, size: 20)
            : const Icon(Icons.text_fields, color: Colors.grey, size: 20),
      ),
    );
  }

  // Mostrar diálogo para selección manual del monto
  void _showManualMontoSelection() {
    setState(() {
      _showManualSelection = true;
    });

    // Agrupar líneas que contienen números
    final linesWithNumbers = _detectedTextLines.where((line) => 
      RegExp(r'\d').hasMatch(line.text)
    ).toList();

    final otherLines = _detectedTextLines.where((line) => 
      !RegExp(r'\d').hasMatch(line.text)
    ).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: widget.notifire.getbackcolor,
          title: Text(
            'Selecciona el monto',
            style: TextStyle(color: widget.notifire.getdarkscolor),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (linesWithNumbers.isNotEmpty) ...[
                  Text(
                    'Líneas con números (más probables):',
                    style: TextStyle(
                      color: widget.notifire.getdarkscolor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: linesWithNumbers.length,
                      itemBuilder: (context, index) {
                        final line = linesWithNumbers[index];
                        return _buildTextLineCard(line, true);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                if (otherLines.isNotEmpty) ...[
                  Text(
                    'Otras líneas detectadas:',
                    style: TextStyle(
                      color: widget.notifire.getdarkscolor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: otherLines.length,
                      itemBuilder: (context, index) {
                        final line = otherLines[index];
                        return _buildTextLineCard(line, false);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showManualEntryOption();
              },
              child: Text(
                'No veo el monto',
                style: TextStyle(color: widget.notifire.getorangeprimerycolor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Procesar la selección manual del usuario
  void _processManualSelection(String selectedText) {
    // Intentar extraer números del texto seleccionado
    final numberRegex = RegExp(r'[\d,]+\.?\d{0,2}');
    final matches = numberRegex.allMatches(selectedText);

    if (matches.isNotEmpty) {
      final match = matches.first;
      final rawNumber = match.group(0)!;
      final cleanNumber = _cleanMonetaryString(rawNumber);
      final value = double.tryParse(cleanNumber.replaceAll(',', ''));

      if (value != null && value > 0) {
        final montoTexto = _formatMonetaryOutput(value);
        setState(() {
          _montoController.text = montoTexto;
          _showManualSelection = false;
          _selectedMontoText = selectedText;
        });

        CherryToast.success(
          title: Text('Monto establecido: L$montoTexto'),
          backgroundColor: widget.notifire.getbackcolor,
        ).show(context);
      } else {
        _showManualEntryWithSuggestion(selectedText);
      }
    } else {
      _showManualEntryWithSuggestion(selectedText);
    }
  }

  // Mostrar opción para ingresar manualmente con sugerencia
  void _showManualEntryWithSuggestion(String suggestion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final suggestionController = TextEditingController(text: suggestion);

        return AlertDialog(
          backgroundColor: widget.notifire.getbackcolor,
          title: Text(
            'Ingresar monto manualmente',
            style: TextStyle(color: widget.notifire.getdarkscolor),
          ),
          content: TextField(
            controller: suggestionController,
            decoration: InputDecoration(
              labelText: 'Texto detectado',
              labelStyle: TextStyle(color: widget.notifire.getdarkscolor),
              border: const OutlineInputBorder(),
            ),
            style: TextStyle(color: widget.notifire.getdarkscolor),
            onChanged: (value) {
              // Extraer números automáticamente mientras escribe
              final numberRegex = RegExp(r'[\d,]+\.?\d{0,2}');
              final match = numberRegex.firstMatch(value);
              if (match != null) {
                final cleanNumber = _cleanMonetaryString(match.group(0)!);
                final numericValue = double.tryParse(cleanNumber.replaceAll(',', ''));
                if (numericValue != null) {
                  suggestionController.value = suggestionController.value.copyWith(
                    text: _formatMonetaryOutput(numericValue),
                    selection: TextSelection.collapsed(offset: _formatMonetaryOutput(numericValue).length),
                  );
                }
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                final text = suggestionController.text;
                final cleanNumber = _cleanMonetaryString(text);
                final value = double.tryParse(cleanNumber.replaceAll(',', ''));

                if (value != null && value > 0) {
                  setState(() {
                    _montoController.text = _formatMonetaryOutput(value);
                    _showManualSelection = false;
                  });
                  Navigator.of(context).pop();

                  CherryToast.success(
                    title: Text('Monto establecido: L${_formatMonetaryOutput(value)}'),
                    backgroundColor: widget.notifire.getbackcolor,
                  ).show(context);
                } else {
                  CherryToast.error(
                    title: const Text('Por favor ingrese un monto válido'),
                    backgroundColor: widget.notifire.getbackcolor,
                  ).show(context);
                }
              },
              child: Text('Aceptar', style: TextStyle(color: widget.notifire.getorangeprimerycolor)),
            ),
          ],
        );
      },
    );
  }

  // Opción para ingresar manualmente sin sugerencias
 void _showManualEntryOption() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final manualController = TextEditingController();

      return AlertDialog(
        backgroundColor: widget.notifire.getbackcolor,
        title: Text(
          'Ingresar monto manualmente',
          style: TextStyle(color: widget.notifire.getdarkscolor),
        ),
        content: TextField(
          controller: manualController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Monto en Lempiras',
            labelStyle: TextStyle(color: widget.notifire.getdarkscolor),
            prefixText: 'L ',
            border: const OutlineInputBorder(),
            hintText: 'Ej: 1,500.00',
          ),
          style: TextStyle(color: widget.notifire.getdarkscolor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              final text = manualController.text;
              final cleanNumber = _cleanMonetaryString(text);
              final value = double.tryParse(cleanNumber.replaceAll(',', ''));

              if (value != null && value > 0) {
                setState(() {
                  _montoController.text = _formatMonetaryOutput(value);
                  _showManualSelection = false;
                });
                Navigator.of(context).pop();

                CherryToast.success(
                  title: Text('Monto establecido: L ${_formatMonetaryOutput(value)}'),
                  backgroundColor: widget.notifire.getbackcolor,
                ).show(context);
              } else {
                CherryToast.error(
                  title: const Text('Por favor ingrese un monto válido en Lempiras'),
                  backgroundColor: widget.notifire.getbackcolor,
                ).show(context);
              }
            },
            child: Text('Aceptar', style: TextStyle(color: widget.notifire.getorangeprimerycolor)),
          ),
        ],
      );
    },
  );
}

 void _showExtractionFeedback(MontoCandidate candidate, int totalCandidates) {
  String confidenceLevel;
  if (candidate.confidence >= 0.9) {
    confidenceLevel = "Alta confianza";
  } else if (candidate.confidence >= 0.7) {
    confidenceLevel = "Media confianza";
  } else {
    confidenceLevel = "Baja confianza";
  }

  CherryToast.info(
    title: Text('Monto detectado: L ${_formatMonetaryOutput(candidate.value)}'),
    description: Text('$confidenceLevel'),
    backgroundColor: widget.notifire.getbackcolor,
    borderRadius: 5,
  ).show(context);
}

  InputDecoration _customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      hintStyle: TextStyle(color: widget.notifire.getdarkscolor),
      labelStyle: TextStyle(color: widget.notifire.getdarkscolor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide:
        BorderSide(color: widget.notifire.getorangeprimerycolor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: widget.notifire.getbackcolor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Registro de Depósito Bancario',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Gilroy Bold',
            color: widget.notifire.getwhite,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: widget.notifire.getorangeprimerycolor,
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
              border: Border.all(color: widget.notifire.getwhite),
            ),
            child: Icon(Icons.arrow_back, color: widget.notifire.getwhite),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreClienteController,
                  decoration: _customInputDecoration('Nombre'),
                  style: TextStyle(color: widget.notifire.getdarkscolor),
                  keyboardType: TextInputType.text,
                  enabled: false,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _identidadController,
                  decoration: _customInputDecoration('Identidad'),
                  style: TextStyle(color: widget.notifire.getdarkscolor),
                  keyboardType: TextInputType.number,
                  enabled: identidad,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La identidad es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: widget.notifire.getdarkscolor),
                      color: widget.notifire.getprimerycolor,
                    ),
                    child: _image == null
                        ? Center(
                      child: Text(
                        'Toque para subir la imagen del depósito',
                        style: TextStyle(
                            color: widget.notifire.getdarkscolor),
                      ),
                    )
                        : Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _image = null;
                                _montoController.clear();
                                _showManualSelection = false;
                                _selectedMontoText = null;
                              });
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 15,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_image == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'La imagen es obligatoria',
                      style: TextStyle(color: widget.notifire.getdarkscolor),
                    ),
                  ),

                // Indicador de selección manual
                if (_showManualSelection && _image != null)
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No se pudo detectar automáticamente el monto. Toque aquí para seleccionarlo manualmente.',
                            style: TextStyle(color: Colors.orange[800]),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.help_outline, color: Colors.orange),
                          onPressed: _showManualMontoSelection,
                        ),
                      ],
                    ),
                  ),

                // Confirmación de monto seleccionado
                if (_selectedMontoText != null)...[
  const SizedBox(height: 20),

                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Monto seleccionado: "$_selectedMontoText"',
                            style: TextStyle(color: Colors.green[800]),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
                              

                const SizedBox(height: 20),
                TextFormField(
                  controller: _telefonoController,
                  style: TextStyle(color: widget.notifire.getdarkscolor),

                  decoration: _customInputDecoration('Número de Teléfono'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El número de teléfono es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _montoController,
                  decoration: _customInputDecoration('Monto'),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: widget.notifire.getdarkscolor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el monto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _comentarioController,
                  decoration: _customInputDecoration('Comentario'),
                  style: TextStyle(color: widget.notifire.getdarkscolor),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      sendDatos();
                    } else {
                      CherryToast.warning(
                        backgroundColor: widget.notifire.getbackcolor,
                        title: Text('Campos Vacios',
                            style:
                            TextStyle(color: widget.notifire.getdarkscolor),
                            textAlign: TextAlign.start),
                        borderRadius: 5,
                      ).show(context);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Custombutton.button(
                        widget.notifire.getorangeprimerycolor,
                        'Realizar Registro',
                        width / 1.5,
                        icon: Icons.attach_money_rounded,
                      ),
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
}

// Clase auxiliar para candidatos de monto
class MontoCandidate {
  final double value;
  final String rawText;
  final double confidence;
  final String reason;
  final TextLine line;

  MontoCandidate({
    required this.value,
    required this.rawText,
    required this.confidence,
    required this.reason,
    required this.line,
  });
}