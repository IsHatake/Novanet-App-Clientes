// ignore_for_file: file_names

import 'dart:convert';

class Pregunta {
  final int numRow;
  final int fiIDPregunta;
  final String fcPregunta;
  final List<Resultado> fcResultado;

  Pregunta({
    required this.numRow,
    required this.fiIDPregunta,
    required this.fcPregunta,
    required this.fcResultado,
  });

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    var list = json['fcResultado'] as String;
    List<dynamic> resultadoList = jsonDecode(list);
    List<Resultado> resultados =
        resultadoList.map((i) => Resultado.fromJson(i)).toList();

    return Pregunta(
      numRow: json['NumRow'],
      fiIDPregunta: json['fiIDPregunta'],
      fcPregunta: json['fcPregunta'],
      fcResultado: resultados,
    );
  }
}

class Resultado {
  final bool value;
  final String text;

  Resultado({required this.value, required this.text});

  factory Resultado.fromJson(Map<String, dynamic> json) {
    return Resultado(
      value: json['value'],
      text: json['text'],
    );
  }

  String get uniqueValue => json.encode({'value': value, 'text': text});
}