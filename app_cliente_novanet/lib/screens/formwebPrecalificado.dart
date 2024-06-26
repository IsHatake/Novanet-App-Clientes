// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class formwebPrecalificado extends StatefulWidget {
  final String fiIdequifax;

  const formwebPrecalificado({Key? key, required this.fiIdequifax})
      : super(key: key);

  @override
  _formwebPrecalificadoState createState() => _formwebPrecalificadoState();
}

class _formwebPrecalificadoState extends State<formwebPrecalificado> {
  late ColorNotifire notifire;
  String url =
      'https://orion.novanetgroup.com/DatosCliente/ViewFormDatosCliente/';

  Future<void> getDarkModePreviousState() async {
    final prefs = await SharedPreferences.getInstance();
    final previousState = prefs.getBool("setIsDark") ?? false;
    notifire.setIsDark = previousState;
  }

  @override
  void initState() {
    super.initState();
    getDarkModePreviousState();
    setState(() {
      url += widget.fiIdequifax;
    });
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Formulario de Cliente',
          style: TextStyle(
            fontSize: 20,
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
      body: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(
              NavigationDelegate(
                onProgress: (int progress) {},
                onPageStarted: (String url) {},
                onPageFinished: (String url) {},
                onWebResourceError: (WebResourceError error) {},
                onNavigationRequest: (NavigationRequest request) {
                  if (request.url.contains(url)) {
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },
              ),
            )
            ..loadRequest(Uri.parse(url))),
    );
  }
}
