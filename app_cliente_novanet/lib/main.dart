import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_cliente_novanet/splashscreen.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ColorNotifire(),
        ),
      ],
      child: const MaterialApp(
        home: Splashscreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
