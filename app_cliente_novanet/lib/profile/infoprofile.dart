
// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/profile/editprofile.dart';
import 'package:app_cliente_novanet/utils/imgProfile.dart';
import 'package:app_cliente_novanet/utils/profiletextfield.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colornotifire.dart';
import '../utils/media.dart';
import '../utils/string.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class _MyProfileState extends State<MyProfile> with RouteAware {
  late ColorNotifire notifire;

  String fcNombreUsuario = '';
  String fcUsuarioAcceso = '';
  String fcTelefono = '';
  String _imagePath = '';

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _imagePath = prefs.getString("fcURLFotoPersonalizda") ?? '';
      fcUsuarioAcceso = prefs.getString('fcUsuarioAcceso') ?? '';
      fcNombreUsuario = prefs.getString('fcNombreUsuario') ?? '';
      fcTelefono = prefs.getString('fcTelefono') ?? '';
    });
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    getdarkmodepreviousstate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Esto se llama cuando volvemos a esta página desde otra.
    _loadData(); // Recargar los datos
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: notifire.getprimerycolor,
        elevation: 0,
        iconTheme: IconThemeData(color: notifire.getdarkscolor),
        title: Text(
          CustomStrings.myprofile,
          style: TextStyle(
              color: notifire.getdarkscolor,
              fontSize: height / 40,
              fontFamily: 'Gilroy Bold'),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfile(),
                ),
              );
            },
            child: Image.asset(
              "images/editprofile.png",
              scale: 3.5,
            ),
          ),
          const SizedBox(
            width: 8,
          )
        ],
      ),
      backgroundColor: notifire.getprimerycolor,
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            image: AssetImage(
              "images/background.png",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: height / 40,
                    ),
                    ImgProfile(height: height, width: width),
                    SizedBox(height: height / 50),
                    Row(
                      children: [
                        SizedBox(
                          width: width / 20,
                        ),
                        Text(
                          CustomStrings.fullnamee,
                          style: TextStyle(
                              color: notifire.getdarkscolor,
                              fontSize: height / 50,
                              fontFamily: 'Gilroy Medium'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height / 50,
                    ),
                    Profiletextfilds.textField(
                        notifire.getprimerycolor,
                        notifire.getdarkscolor,
                        notifire.getorangeprimerycolor,
                        fcNombreUsuario,
                        notifire.getdarkwhitecolor,
                        true),
                    SizedBox(
                      height: height / 50,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: width / 20,
                        ),
                        Text(
                          CustomStrings.email,
                          style: TextStyle(
                              color: notifire.getdarkscolor,
                              fontSize: height / 50,
                              fontFamily: 'Gilroy Medium'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height / 50,
                    ),
                    Profiletextfilds.textField(
                        notifire.getdarkscolor,
                        notifire.getdarkscolor,
                        notifire.getorangeprimerycolor,
                        fcUsuarioAcceso,
                        notifire.getdarkwhitecolor,
                        true),
                    SizedBox(
                      height: height / 50,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: width / 20,
                        ),
                        Text(
                          CustomStrings.phonenumber,
                          style: TextStyle(
                              color: notifire.getdarkscolor,
                              fontSize: height / 50,
                              fontFamily: 'Gilroy Medium'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height / 50,
                    ),
                    Profiletextfilds.textField(
                        notifire.getdarkscolor,
                        notifire.getdarkscolor,
                        notifire.getorangeprimerycolor,
                        fcTelefono,
                        notifire.getdarkwhitecolor,
                        true),
                    SizedBox(
                      height: height / 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
