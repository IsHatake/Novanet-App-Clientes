// // ignore_for_file: use_key_in_widget_constructors, import_of_legacy_library_into_null_safe, camel_case_types, library_private_types_in_public_api, unused_import

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:app_cliente_novanet/utils/colornotifire.dart';
// import 'package:app_cliente_novanet/utils/media.dart';
// import 'package:app_cliente_novanet/utils/string.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// //import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:signalr_client/signalr_client.dart';
// import 'package:http/http.dart' as http;

// class support_screen extends StatefulWidget {
//   @override
//   _support_screenState createState() => _support_screenState();
// }

// class _support_screenState extends State<support_screen> {
//   final hubConnection = HubConnectionBuilder()
//       .withUrl('https://api.novanetgroup.com/notificaciones')
//       .build();

//   TextEditingController messageController = TextEditingController();
//   List<String> messages = [];
//   late ColorNotifire notifire;

//   @override
//   void initState() {
//     super.initState();

//     // Conectar a SignalR Hub
//     _startHubConnection();

//     // Recibimiento de Notificacions Api
//     hubConnection.on('SendNotificacion', _handleReceivedMessage);
//   }

//   void _startHubConnection() async {
//     try {
//       await hubConnection.start();
//       if (kDebugMode) {
//         print('SignalR conexion iniciada.');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error de conexión a SignalR: $e');
//       }
//     }
//   }

//   void _handleReceivedMessage(List<Object?> arguments) {
//     var listArguments = [];
//     var users = [];
//     String? message;

//     if (arguments.isNotEmpty) {
//       for (var arguments in arguments) {
//         listArguments.add(arguments);

//         if (listArguments.isNotEmpty) {
//           listArguments[0][0].forEach((element) {
//             users.add(element);
//           });
//         }
//       }
//       message = listArguments[0][1];
//     }

//     if (kDebugMode) {
//       print("usuarios: $users");
//     }
//     if (kDebugMode) {
//       print("mensaje: $message");
//     }

//     setState(() {
//       messages.add('$message');
//     });
//   }

//   Future<void> _sendMessage() async {
//     String user = 'IsHatake';
//     String message = messageController.text;

//     // Envio de Mensajes Api
//     hubConnection.invoke('Get', args: [user, message]);
//     await http.get(Uri.parse(
//         'https://api.novanetgroup.com/api/Novanet/SignalR/Get?message=$message'));

//     // Clear the text input field
//     messageController.text = '';
//   }

//   Future<void> getDarkModePreviousState() async {
//     final prefs = await SharedPreferences.getInstance();
//     final previousState = prefs.getBool("setIsDark") ?? false;
//     notifire.setIsDark = previousState;
//   }

//   @override
// Widget build(BuildContext context) {
//   notifire = Provider.of<ColorNotifire>(context, listen: true);
//   return MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: Scaffold(
//       backgroundColor: notifire.getbackcolor,
//       appBar: AppBar(
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           CustomStrings.support,
//           style: TextStyle(
//             fontSize: 20,
//             fontFamily: 'Gilroy Bold',
//             color: notifire.getdarkscolor,
//           ),
//         ),
//         backgroundColor: notifire.getorangeprimerycolor,
//         leading: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Container(
//             height: 40,
//             width: 40,
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: notifire.getdarkscolor),
//             ),
//             child: Icon(Icons.arrow_back, color: notifire.getdarkscolor),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             flex: 1,
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(messages[index]),
//                 );
//               },
//             ),
//           ),
//           Padding( 
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     autofocus: false,
//                     style: TextStyle(
//                       fontSize: height / 50,
//                       color: notifire.getdarkscolor,
//                     ),
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: notifire.getprimerycolor,
//                       hintText: 'Escribe un mensaje',
//                       hintStyle:
//                           TextStyle(color: notifire.getdarkgreycolor, fontSize: height / 60),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: notifire.getorangeprimerycolor),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide:
//                             const BorderSide(color: Color(0xffd3d3d3)),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     Icons.send,
//                     color: notifire.getorangeprimerycolor,
//                   ),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }


//   @override
//   void dispose() {
//     hubConnection.stop();
//     super.dispose();
//   }
// }
