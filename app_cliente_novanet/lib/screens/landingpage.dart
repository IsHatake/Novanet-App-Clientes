// ignore_for_file: unused_field

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/login/login.dart';
import 'package:app_cliente_novanet/screens/registerclient.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _checkFirstVisit();
  }

  bool _showRegisterButton = false;
  bool _showLoginButton = false;
  Future<void> _checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstVisit = prefs.getBool('isFirstVisitLanding') ?? true;

    if (isFirstVisit) {
      await _showExplanationDialog();
      await prefs.setBool('isFirstVisitLanding', false);
    }
  }

  Future<void> _showExplanationDialog() async {
    Widget dialogContent;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      dialogContent = CupertinoAlertDialog(
        title: const Text('Bienvenido'),
        content: Column(
          children: [
            ClipOval(
              child: Image.asset(
                'images/informacionnecesaria.gif',
                height: 200,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(
                  CupertinoIcons.person_add,
                  color: Colors.orange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Usa el registrar si necesitas llenar el formulario de precalificado.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(
                  CupertinoIcons.person_alt,
                  color: Colors.orange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Usa el Inicio de Sesión si necesitas iniciar sesión como usuario principal, secundario o crear un perfil de usuario secundario.',
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('Entendido'),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _showRegisterButton = true;
                _showLoginButton = true;
              });
            },
          ),
        ],
      );
    } else {
      dialogContent = AlertDialog(
        title: const Text('Bienvenido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                'images/informacionnecesaria.gif',
                height: 200,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(
                  Icons.person_add,
                  color: Colors.orange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Usa el registrar si necesitas llenar el formulario de precalificado.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(
                  Icons.person,
                  color: Colors.orange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Usa el Inicio de Sesión si necesitas iniciar sesión como usuario principal, secundario o crear un perfil de usuario secundario.',
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Entendido'),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _showRegisterButton = true;
                _showLoginButton = true;
              });
            },
          ),
        ],
      );
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return dialogContent;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: height,
            width: width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/fondolanding.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment(0.2, 0),
              ),
            ),
          ),
          Container(
            height: height,
            width: width,
            color: Colors.black.withOpacity(0.4),
            child: Column(
              children: [
                const Spacer(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Image.asset(
                          'images/logos.png',
                          height: height * 0.2,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '¡Más velocidad a tu alcance!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 3,
                                color: Colors.black54,
                              ),
                            ],
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: width * 0.8,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Registerclient(),
                        ),
                      );
                    },
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: width * 0.8,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                    },
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
