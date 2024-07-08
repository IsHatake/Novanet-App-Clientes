import 'package:app_cliente_novanet/screens/adduserFamily.dart';
import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:app_cliente_novanet/utils/button.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math'; // Import for the shuffle
import 'package:app_cliente_novanet/models/PreguntasViewModel.dart';
import 'package:provider/provider.dart';

class PreguntaFormScreen extends StatefulWidget {
  final String fcIdentidad;
  final int fiIDEquifax;
  final bool redireccion;
  final bool fbprincipal;

  const PreguntaFormScreen({
    Key? key,
    required this.fcIdentidad,
    required this.fiIDEquifax,
    required this.redireccion,
    required this.fbprincipal,
  }) : super(key: key);

  @override
  _PreguntaFormScreenState createState() => _PreguntaFormScreenState();
}

class _PreguntaFormScreenState extends State<PreguntaFormScreen> {
  late ColorNotifire notifire;
  late Future<List<Pregunta>> _preguntas;
  final Map<int, String> _selectedValues = {};

  @override
  void initState() {
    super.initState();
    _preguntas = fetchPreguntas();
  }

  Future<List<Pregunta>> fetchPreguntas() async {
    final response = await http.get(Uri.parse(
        'https://api.novanetgroup.com/api/Novanet/Usuario/Preguntas?fcIdentidad=${widget.fcIdentidad}'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Pregunta.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load preguntas');
    }
  }

  Future<void> _verifyAnswers() async {
    if (_selectedValues.length < 3) {
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'Por favor, conteste todas las preguntas',
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    int aciertos = 0;
    _selectedValues.forEach((key, value) {
      if (json.decode(value)['value'] == true) {
        aciertos++;
      }
    });

    if (aciertos > 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdduserFamily(
            fiIDEquifax: widget.fiIDEquifax,
            redireccion: widget.redireccion,
            fbprincipal: widget.fbprincipal,
          ),
        ),
      );
    } else {
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'No hay suficientes respuestas correctas',
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);

      await Future.delayed(const Duration(seconds: 3));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getprimerycolor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Formulario de Validación',
          style: TextStyle(
            fontSize: 15,
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
      ),
      body: FutureBuilder<List<Pregunta>>(
        future: _preguntas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 60,
                          ),
                          Center(
                            child: Image.asset(
                              "images/logos.png",
                              height: MediaQuery.of(context).size.height / 8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      ...snapshot.data!.map((pregunta) => PreguntaWidget(
                            pregunta: pregunta,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedValues[pregunta.fiIDPregunta] =
                                    newValue!;
                              });
                            },
                          )),
                      const SizedBox(height: 50),
                      GestureDetector(
                        onTap: () {
                          _verifyAnswers();
                        },
                        child: Custombutton.button(
                          notifire.getorangeprimerycolor,
                          "Verificar",
                          MediaQuery.of(context).size.width / 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

class PreguntaWidget extends StatelessWidget {
  final Pregunta pregunta;
  final ValueChanged<String?>? onChanged;

  const PreguntaWidget({
    Key? key,
    required this.pregunta,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Resultado> shuffledResultados = List.from(pregunta.fcResultado)
      ..shuffle(Random());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pregunta.fcPregunta,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: null, // Ensure the initial value is null
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Seleccione una opción',
              ),
              items: shuffledResultados.map((Resultado resultado) {
                return DropdownMenuItem<String>(
                  value: resultado.uniqueValue,
                  child: Text(resultado.text),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
