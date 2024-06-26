import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/utils/media.dart';
import 'package:app_cliente_novanet/utils/string.dart';
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

  List<String> notificationtxt = [
    CustomStrings.successfully,
    CustomStrings.lockdown,
    CustomStrings.wayorder,
    CustomStrings.prepared,
    CustomStrings.discount,
  ];
  List<String> notificationtxt2 = [
    CustomStrings.yesterday,
    CustomStrings.mar,
    CustomStrings.mar1,
    CustomStrings.mar2,
    CustomStrings.mar3,
  ];
  List<String> notificationimg = [
    "images/successfull.png",
    "images/lockdown.png",
    "images/order.png",
    "images/banktransfer.png",
    "images/bankinsurance.png",
  ];

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
                child: Column(
                  children: [
                    Container(
                      height: height / 1.5,
                      width: width,
                      color: Colors.transparent,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notificationtxt.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) => Column(
                          children: [
                            _notificationItem(
                              notifire.getprimerycolor,
                              'images/logos.png',
                              notificationtxt[index],
                              notificationtxt2[index],
                            ),
                            SizedBox(
                              height: height / 60,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () {
              _showConfirmationDialog(context);
            },
            child: const Icon(Icons.delete),
            backgroundColor: Colors.red,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(32.0),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: notifire.getprimerycolor,
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            height: height / 2.5,
            child: Column(
              children: [
                SizedBox(
                  height: height / 40,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Icon(
                        Icons.clear,
                        color: notifire.getdarkscolor,
                      ),
                      SizedBox(
                        width: width / 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height / 40,
                ),
                Text(
                  '¿Estás seguro de que quieres eliminar todas las notificaciones?',
                  style: TextStyle(
                    color: notifire.getdarkscolor,
                    fontFamily: 'Gilroy Bold',
                    fontSize: height / 40,
                  ),
                ),
                SizedBox(
                  height: height / 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: height / 18,
                    width: width / 2.5,
                    decoration: BoxDecoration(
                      color: notifire.getorangeprimerycolor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        CustomStrings.cancel,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Gilroy Bold',
                            fontSize: height / 55),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height / 100,
                ),
                GestureDetector(
                  onTap: () {
                    _clearNotifications();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: height / 18,
                    width: width / 2.5,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Eliminar Notificaciones',
                        style: TextStyle(
                            color: const Color(0xffEB5757),
                            fontFamily: 'Gilroy Bold',
                            fontSize: height / 55),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _clearNotifications() {
    setState(() {
      notificationtxt.clear();
      notificationtxt2.clear();
      notificationimg.clear();
    });
  }
}
