// ignore_for_file: file_names, non_constant_identifier_names

class Imagen {
  String? base64;
  String? nombreArchivo;
  int? piIDUnico;
 

  Imagen({
      this.base64,
      this.nombreArchivo,
      this.piIDUnico,
      });

  factory Imagen.fromJson(Map<String, dynamic> json) {
    return Imagen(
      base64: json['base64'],
      nombreArchivo: json['nombreArchivo'],
      piIDUnico: json['piIDUnico'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "base64": base64,
      "nombreArchivo": nombreArchivo,
      "piIDUnico": piIDUnico,
    };
  }
}
