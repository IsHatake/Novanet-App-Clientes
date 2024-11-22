import 'dart:convert';
import 'package:app_cliente_novanet/api.dart';
import 'package:http/http.dart' as http;

class PagoService {
  final baseURL = Uri.parse(apiUrl);

  Future<List<Map<String, dynamic>>> getDataClient(String pcLlaveUnica) async {
    try {
      final uri = Uri.parse("${baseURL}Servicio/InformacionPago")
          .replace(queryParameters: {"pcLlaveUnica": pcLlaveUnica});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.asMap().entries.map((entry) {
          final item = entry.value as Map<String, dynamic>;
          return {
            "key": entry.key + 1,
            "fcIDPrestamo": item["fcIDPrestamo"],
            "fcNombre": item["fcNombre"],
            "fcTelefono": item["fcTelefono"],
            "fcCiudad": item["fcCiudad"],
            "fcIdentidad": item["fcIdentidad"],
            "fnValorCuota": item["fnValorCuota"],
            "fnValorCuotaMonedaNacional": item["fnValorCuotaMonedaNacional"],
            "fcCorreo": item["fcCorreo"],
            "fcDireccionDetallada": item["fcDireccionDetallada"],
            "fiIDUnicoPrestamo": item["fiIDUnicoPrestamo"],
          };
        }).toList();
      } else {
        throw Exception(
            "Error en getDataClient: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error en getDataClient: $e");
      rethrow;
    }
  }

  Future<List<Map<String, String>>> prestamosDDL(
      List<Map<String, dynamic>> prestamos) async {
    try {
      List<Map<String, String>> data = prestamos.map((item) {
        return {
          "value": jsonEncode(item),
          "label":
              "${item["fiIDUnicoPrestamo"]} ${item["fnValorCuotaMonedaNacional"]}",
        };
      }).toList();

      return data;
    } catch (e) {
      print("Error en prestamosDDL: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> abono(Map<String, dynamic> data) async {
    try {
      final datos = {
        "piIDApp": data["piIDApp"] ?? 118,
        "piIDUsuario": data["piIDUsuario"] ?? 337,
        "pcIP": data["pcIP"] ?? "",
        "pcIdentidad": data["pcIdentidad"] ?? "",
        "pnValordelAbono": data["pnValordelAbono"] ?? 0.00,
        "pcIDPrestamo": data["pcIDPrestamo"] ?? "",
        "pcComentarioAdicional": data["pcComentarioAdicional"] ?? "",
        "pcReferencia": data["pcReferencia"] ?? "",
        "piIDTransaccion": data["piIDTransaccion"] ?? "",
        "pcRespuestaPOS": data["pcRespuestaPOS"] ?? "",
      };

      final uri = Uri.parse("${baseURL}Servicio/AplicarAbono");
      final response = await http.post(uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(datos));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Error en abono: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error en abono: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> log(Map<String, dynamic> data) async {
    try {
      final datos = {
        "Pago": data["Pago"] ?? "",
        "Descripciondebito": data["Descripciondebito"] ?? "",
        "Cliente": data["Cliente"] ?? "",
        "TotalPago": data["TotalPago"] ?? 0.00,
        "RespuestaApi": data["RespuestaApi"] ?? "",
        "Comentario": data["Comentario"] ?? "",
      };

      final uri = Uri.parse("${baseURL}Servicio/LogIntentosPago");
      final response = await http.post(uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(datos));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Error en log: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error en log: $e");
      rethrow;
    }
  }
}
