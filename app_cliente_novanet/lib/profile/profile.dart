import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/home/notifications.dart';
import 'package:app_cliente_novanet/home/seealltransaction.dart';
import 'package:app_cliente_novanet/login/login.dart';
import 'package:app_cliente_novanet/screens/adduserFamily.dart';
import 'package:app_cliente_novanet/utils/imgProfile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colornotifire.dart';
import '../utils/media.dart';
import '../utils/string.dart';
import 'forgotpassword.dart';
import 'infoprofile.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class _ProfileState extends State<Profile> with RouteAware {
  late ColorNotifire notifire;
  bool _switchValue = false;
  String fcNombreUsuario = '';
  String fcUsuarioAcceso = '';

  TextEditingController base = TextEditingController();

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      fcUsuarioAcceso = prefs.getString('fcUsuarioAcceso') ?? '';
      fcNombreUsuario = prefs.getString('fcNombreUsuario') ?? '';
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
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: notifire.getdarkscolor),
        elevation: 0,
        backgroundColor: notifire.getprimerycolor,
        title: Text(
          CustomStrings.profile,
          style: TextStyle(
              color: notifire.getdarkscolor,
              fontFamily: 'Gilroy Bold',
              fontSize: height / 40),
        ),
        centerTitle: true,
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
                    SizedBox(
                      height: height / 30,
                    ),
                    Text(
                      fcNombreUsuario,
                      style: TextStyle(
                          fontSize: height / 50,
                          fontFamily: 'Gilroy Bold',
                          color: notifire.getdarkscolor),
                    ),
                    SizedBox(height: height / 100),
                    Text(
                      fcUsuarioAcceso,
                      style: TextStyle(
                        fontSize: height / 55,
                        fontFamily: 'Gilroy Medium',
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: height / 50),
                    Row(
                      children: [
                        SizedBox(
                          width: width / 20,
                        ),
                        const Text(
                          CustomStrings.personalinfo,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height / 50,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyProfile(),
                          ),
                        );
                      },
                      child: settingtype(
                          "images/profile.png", CustomStrings.yourprofile),
                    ),
                    SizedBox(
                      height: height / 80,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width / 20),
                      child: Divider(
                        thickness: 0.8,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                    ),
                    
                     SizedBox(
                      height: height / 50,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdduserFamily(),
                          ),
                        );
                      },
                      child: settingtype(
                          "images/familia.png", CustomStrings.usuariosFamiliares),
                    ),
                    SizedBox(
                      height: height / 80,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width / 20),
                      child: Divider(
                        thickness: 0.8,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                    ),
                    
                    SizedBox(height: height / 80),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Seealltransaction(),
                          ),
                        );
                      },
                      child: settingtype("images/history.png",
                          CustomStrings.historytransaction),
                    ),
                    SizedBox(
                      height: height / 80,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width / 20),
                      child: Divider(
                        thickness: 0.6,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                    ),
                    SizedBox(height: height / 50),
                    Row(
                      children: [
                        SizedBox(
                          width: width / 20,
                        ),
                        const Text(
                          CustomStrings.security,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height / 50),

                    darkmode("images/darkmode.png", CustomStrings.darkmode),
                    // SizedBox(height: height / 100,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width / 20),
                      child: Divider(
                        thickness: 0.7,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                    ),
                    SizedBox(height: height / 80),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPassword(),
                          ),
                        );
                      },
                      child: settingtype("images/profilepassword.png",
                          CustomStrings.changepassword),
                    ),
                  
                    SizedBox(
                      height: height / 80,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width / 20),
                      child: Divider(
                        thickness: 0.6,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                    ),
                    SizedBox(height: height / 50),
                    Row(
                      children: [
                        SizedBox(
                          width: width / 20,
                        ),
                        const Text(
                          CustomStrings.general,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height / 50,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Notificationindex(
                                CustomStrings.notification),
                          ),
                        );
                      },
                      child: settingtype("images/notification.png",
                          CustomStrings.notification),
                    ),
                    SizedBox(height: height / 80),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width / 20),
                      child: Divider(
                        thickness: 0.6,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                    ),
                    SizedBox(height: height / 80),
                    GestureDetector(
                      onTap: () {
                        _showMyDialog();
                      },
                      child: Container(
                        width: width / 2,
                        height: height / 20,
                        color: Colors.transparent,
                        child: Center(
                          child: Text(
                            CustomStrings.logout,
                            style: TextStyle(
                                color: const Color(0xffEB5757),
                                fontFamily: 'Gilroy Bold',
                                fontSize: height / 50),
                          ),
                        ),
                      ),
                    ),
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

  Future<void> _showMyDialog() async {
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
            height: height / 3,
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
                  CustomStrings.sure,
                  style: TextStyle(
                    color: notifire.getdarkscolor,
                    fontFamily: 'Gilroy Bold',
                    fontSize: height / 40,
                  ),
                ),
                Text(
                  CustomStrings.log,
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
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                      (route) =>
                          false,
                    );
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
                        CustomStrings.logout,
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

  Widget faceid(image, title) {
    return Row(
      children: [
        SizedBox(width: width / 20),
        Image.asset(
          image,
          height: height / 34,
          color: notifire.getdarkscolor,
        ),
        SizedBox(width: width / 30),
        Text(
          title,
          style: TextStyle(
            color: notifire.getdarkscolor,
            fontSize: height / 50,
            fontFamily: 'Gilroy Bold',
          ),
        ),
        const Spacer(),
        Transform.scale(
          scale: 0.7,
          child: CupertinoSwitch(
            trackColor: notifire.getdarkgreycolor,
            thumbColor: Colors.white,
            activeColor: notifire.getbluecolor,
            value: _switchValue,
            onChanged: (value) {
              setState(
                () {
                  _switchValue = value;
                },
              );
            },
          ),
        ),
        SizedBox(width: width / 20)
      ],
    );
  }

  Widget darkmode(image, title) {
    return Row(
      children: [
        SizedBox(width: width / 20),
        Image.asset(
          image,
          height: height / 34,
          color: notifire.getdarkscolor,
        ),
        SizedBox(width: width / 30),
        Text(
          title,
          style: TextStyle(
            color: notifire.getdarkscolor,
            fontSize: height / 50,
            fontFamily: 'Gilroy Bold',
          ),
        ),
        const Spacer(),
        Transform.scale(
          scale: 0.7,
          child: CupertinoSwitch(
            trackColor: notifire.getdarkgreycolor,
            thumbColor: Colors.white,
            activeColor: notifire.getbluecolor,
            value: notifire.getIsDark,
            onChanged: (val) async {
              final prefs = await SharedPreferences.getInstance();
              setState(
                () {
                  notifire.setIsDark = val;
                  prefs.setBool("setIsDark", val);
                },
              );
            },
          ),
        ),
        SizedBox(width: width / 20)
      ],
    );
  }

  Widget settingtype(image, title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width / 20),
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            Image.asset(
              image,
              height: height / 34,
              color: notifire.getdarkscolor,
            ),
            SizedBox(width: width / 30),
            Text(
              title,
              style: TextStyle(
                color: notifire.getdarkscolor,
                fontSize: height / 50,
                fontFamily: 'Gilroy Bold',
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget logout(image, title) {
    return Row(
      children: [
        SizedBox(width: width / 20),
        Image.asset(image, height: height / 27),
        SizedBox(width: width / 30),
        Text(
          title,
          style: TextStyle(
            color: const Color(0xffF75555),
            fontSize: height / 50,
            fontFamily: 'Gilroy Bold',
          ),
        ),
      ],
    );
  }
}
