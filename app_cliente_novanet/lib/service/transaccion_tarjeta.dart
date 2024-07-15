// import 'package:pixelpay_sdk/models/item.dart' as pixelpay;
// import 'package:pixelpay_sdk/models/order.dart' as pixelpay;
// import 'package:pixelpay_sdk/models/settings.dart' as pixelpay;
// import 'package:pixelpay_sdk/entities/transaction_result.dart' as pixelpay;
// import 'package:pixelpay_sdk/requests/auth_transaction.dart' as pixelpay;
// import 'package:pixelpay_sdk/services/transaction.dart' as pixelpay;

// void main() async {
//   try {
//     final settings = pixelpay.Settings();
//     settings.setupEndpoint("https://{endpoint}");
//     settings.setupCredentials("2222222222", "elhashmd5delsecretkeydelcomercio");

//     final item = pixelpay.Item();
//     item.code = "00001";                              //prestamo
//     item.title = "Videojuego";                        // producto
//     item.price = 1000;                                //valor en lempiras
//     item.qty = 1;

//     final order = pixelpay.Order();
//     order.id = "ORDER-12948";                         //prestamo
//     order.customer_name = "SERGIO PEREZ";             //nombre de la tarjeta (llenado a mano)
//     order.currency = "HNL";                           //moneda
//     order.customer_email = "sergio.perez@gmail.com";  //email de cliente
//     order.addItem(item);

//     String token = "T-1cb07ea3-d45c-4a64-a081-68078b8fc796";

//     final auth = pixelpay.AuthTransaction();
//     auth.setOrder(order);
//     auth.setCardToken(token);

//     final service = pixelpay.Transaction(settings);
//     final response = await service.doAuth(auth);

//     if (pixelpay.TransactionResult.validateResponse(response!)) {
//       final result = pixelpay.TransactionResult.fromResponse(response);
//       // Éxito: manejo del resultado de la autenticación
//       print("Autenticación exitosa.");
//     } else {
//       // Error: respuesta de autenticación inválida
//       print("Error: Respuesta de autenticación inválida.");
//     }
//   } catch (e) {
//     // Manejo de errores generales
//     print("Error: $e");
//   }
// }
