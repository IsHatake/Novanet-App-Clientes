import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/utils/media.dart';
import 'package:app_cliente_novanet/utils/string.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/colornotifire.dart';

class Notificationindex extends StatefulWidget {
  final String title;
  const Notificationindex(this.title, {Key? key}) : super(key: key);

  @override
  State<Notificationindex> createState() => _NotificationindexState();
}

class _NotificationindexState extends State<Notificationindex> {
  late ColorNotifire notifire;

  List<Map<String, String>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fiIDCuentaFamiliar = prefs.getString("fiIDCuentaFamiliar");

    if (fiIDCuentaFamiliar != null) {
      final response = await http.get(Uri.parse(
          'https://api.novanetgroup.com/api/Novanet/Usuario/Notificaciones?fiIDEquifax=$fiIDCuentaFamiliar'));

      if (response.statusCode == 200) {
        final List<dynamic> notificacionesJson =
            jsonDecode(response.body)['data'];

        setState(() {
          notifications = notificacionesJson
              .where((noti) => noti['fbVisibilidad'] != false)
              .map((noti) {
            String formattedDate =
                DateTime.parse(noti['fdFechaEnvio']).toString().split('T')[0];

            return {
              'id': noti['fiIDNotificacion'].toString(),
              'title': noti['fcNotificacion'].toString(),
              'date': formattedDate,
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    }
  }

  void _deleteNotification(String? index) async {
    final response = await http.get(Uri.parse(
        'https://api.novanetgroup.com/api/Novanet/Usuario/Notificaciones_By_Cliente_Eliminar?piIDNotificacion=$index'));

    // Lógica para eliminar la notificación de la lista local
    setState(() {
      notifications.removeWhere((notification) => notification['id'] == index);
    });
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: notifire.getprimerycolor,
        iconTheme: IconThemeData(color: notifire.getdarkscolor),
        title: Text(
          CustomStrings.notification,
          style: TextStyle(
            color: notifire.getdarkscolor,
            fontFamily: 'Gilroy Bold',
            fontSize: height / 40,
          ),
        ),
      ),
      backgroundColor: notifire.getprimerycolor,
      body: Stack(
        children: [
          Image.asset(
            "images/background.png",
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              SizedBox(
                height: height / 30,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width / 20),
                child: notifications.isEmpty
                    ? Center(
                        child: Text(
                          'Sin notificaciones previas',
                          style: TextStyle(
                            color: notifire.getdarkscolor,
                            fontFamily: 'Gilroy Bold',
                            fontSize: height / 40,
                          ),
                        ),
                      )
                    : Container(
                        height: height / 1.5,
                        width: width,
                        color: Colors.transparent,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notifications.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) => Column(
                            children: [
                              Dismissible(
                                key: UniqueKey(),
                                direction: DismissDirection.startToEnd,
                                onDismissed: (direction) {
                                  _deleteNotification(
                                      notifications[index]['id']);
                                },
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                child: _notificationItem(
                                  notifire.getprimerycolor,
                                  'images/logos.png',
                                  notifications[index]['title']!,
                                  DateFormat('dd/MM/yyyy hh:mm:ss a').format(
                                    DateTime.parse(
                                      notifications[index]['date']!,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height / 60,
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _notificationItem(clr, img, txt, txt2) {
    return Container(
      height: height / 11,
      width: width,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        color: notifire.gettabcolor,
      ),
      child: Row(
        children: [
          SizedBox(
            width: width / 35,
          ),
          Container(
            height: height / 15,
            width: width / 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: clr,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(height / 70),
                child: Image.asset(img),
              ),
            ),
          ),
          SizedBox(
            width: width / 50,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: height / 60,
                ),
                Text(
                  txt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                      color: notifire.getdarkscolor,
                      fontFamily: 'Gilroy Bold',
                      fontSize: height / 54),
                ),
                SizedBox(
                  height: height / 100,
                ),
                Text(
                  txt2,
                  style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Gilroy Medium',
                      fontSize: height / 55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
