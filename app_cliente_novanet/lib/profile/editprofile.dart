// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/models/ImagenViewModel.dart';
import 'package:app_cliente_novanet/utils/imgProfile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

import '../api.dart';
import '../utils/colornotifire.dart';
import '../utils/media.dart';
import '../utils/profiletextfield.dart';
import '../utils/string.dart';
import '../profile/infoprofile.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late ColorNotifire notifire;

  String fcNombreUsuario = '';
  String fcUsuarioAcceso = '';
  String fcTelefono = '';
  String fiIDUnico = '';

  bool _isUploading = false;

  TextEditingController base = TextEditingController();

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      fiIDUnico = prefs.getString("fiIDUnico") ?? '';
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
    _loadData();
    super.initState();
    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: notifire.getprimerycolor,
        iconTheme: IconThemeData(color: notifire.getdarkscolor),
        elevation: 0,
        title: Text(
          CustomStrings.myprofile,
          style: TextStyle(
              color: notifire.getdarkscolor,
              fontSize: height / 40,
              fontFamily: 'Gilroy Bold'),
        ),
        centerTitle: true,
      ),
      backgroundColor: notifire.getprimerycolor,
      body: _isUploading
          ? Center(
              child: CircularProgressIndicator(
              color: notifire.getorangeprimerycolor,
            ))
          : SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    height: height * 0.8,
                    width: width,
                    color: Colors.transparent,
                    child: Image.asset(
                      "images/background.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(height: height / 60),
                      Stack(
                        children: [
                          Center(
                            child: ImgProfile(height: height, width: width),
                          ),
                          Column(
                            children: [
                              Column(
                                children: [
                                  SizedBox(height: height / 13),
                                  Row(
                                    children: [
                                      SizedBox(width: width / 1.8),
                                      GestureDetector(
                                        onTap: () {
                                          _showOptionsDialog(context);
                                        },
                                        child: Image.asset(
                                          "images/camera.png",
                                          height: height / 25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: height / 30),
                      _buildLabel(CustomStrings.fullnamee),
                      SizedBox(height: height / 50),
                      Profiletextfilds.textField(
                        notifire.getdarkscolor,
                        notifire.getdarkgreycolor,
                        notifire.getorangeprimerycolor,
                        fcNombreUsuario,
                        notifire.getdarkwhitecolor,
                        false,
                      ),
                      SizedBox(height: height / 50),
                      _buildLabel(CustomStrings.email),
                      SizedBox(height: height / 50),
                      Profiletextfilds.textField(
                        notifire.getdarkscolor,
                        notifire.getdarkgreycolor,
                        notifire.getorangeprimerycolor,
                        fcUsuarioAcceso,
                        notifire.getdarkwhitecolor,
                        false,
                      ),
                      SizedBox(height: height / 50),
                      _buildLabel(CustomStrings.phonenumbers),
                      SizedBox(height: height / 50),
                      Profiletextfilds.textField(
                        notifire.getdarkscolor,
                        notifire.getdarkgreycolor,
                        notifire.getorangeprimerycolor,
                        fcTelefono,
                        notifire.getdarkwhitecolor,
                        false,
                      ),
                      SizedBox(height: height / 20),
                      _buildSaveButton(context),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Row(
      children: [
        SizedBox(width: width / 20),
        Text(
          text,
          style: TextStyle(
            color: notifire.getdarkscolor,
            fontSize: height / 50,
            fontFamily: 'Gilroy Medium',
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width / 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyProfile(),
            ),
          );
        },
        child: Container(
          height: height / 15,
          width: width,
          decoration: BoxDecoration(
            color: notifire.getorangeprimerycolor,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Center(
            child: Text(
              CustomStrings.savechange,
              style: TextStyle(
                color: Colors.white,
                fontSize: height / 50,
                fontFamily: 'Gilroy Bold',
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0),
          content: SingleChildScrollView(
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    selImagen(1);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Tomar una foto',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Icon(
                          Icons.camera_alt_outlined,
                          color: notifire.getorangeprimerycolor,
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    selImagen(2);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Elegir de Galería',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Icon(
                          Icons.photo,
                          color: notifire.getorangeprimerycolor,
                        ),
                      ],
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

  Future<void> selImagen(int op) async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? pickedFile;

      if (op == 1) {
        pickedFile = await picker.pickImage(source: ImageSource.camera);
        Navigator.pop(context);
      } else {
        pickedFile = await picker.pickImage(source: ImageSource.gallery);
        Navigator.pop(context);
      }

      if (pickedFile != null) {
        List<int> bytes = await pickedFile.readAsBytes();
        Uint8List bytes2 = Uint8List.fromList(bytes);

        Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
          bytes2,
          minHeight: 1500,
          minWidth: 900,
          quality: 90,
        );
        String fileName = pickedFile.name;
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex != -1) {
          fileName = fileName.substring(0, dotIndex);
        }

        String base64Image = base64Encode(compressedBytes);

        String sanitizedUserName = fcNombreUsuario.replaceAll(' ', '_');
        String nombreArchivo =
            'FotoPerfil_${sanitizedUserName}_${fileName}_$fiIDUnico';

        setState(() {
          _isUploading = true;
        });
        await subirImagen(context, base64Image, nombreArchivo);
      }
    } catch (e) {
      if (kDebugMode) {
        print('error: $e');
      }
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> subirImagen(
      BuildContext context, String img, String nombreArchivo) async {
    try {
      Imagen imagenData = Imagen(
          base64: img,
          nombreArchivo: nombreArchivo,
          piIDUnico: int.tryParse(fiIDUnico));

      String imagenJson = jsonEncode(imagenData);

      final response = await http.post(
        Uri.parse('${apiUrl}Usuario/CambioImagen'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: imagenJson,
      );

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        final codeStatus = decodedJson["code"];
        final messageStatus = decodedJson["message"];

        if (codeStatus.toString() == '200') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove('fcURLFotoPersonalizda');
          String fcurl =
              'https://orion.novanetgroup.com/ImagenesOrion.ashx?type=img&carpeta=\\Documento\\imgAppNovanet&documento=$nombreArchivo.png';

          prefs.setString("fcURLFotoPersonalizda", fcurl);

          await reloadImage();

          CherryToast.success(
            backgroundColor: notifire.getbackcolor,
            title: Text(
              '$messageStatus',
              style: TextStyle(color: notifire.getdarkscolor),
              textAlign: TextAlign.start,
            ),
            borderRadius: 5,
          ).show(context);
        } else {
          CherryToast.error(
            backgroundColor: notifire.getbackcolor,
            title: Text('$messageStatus',
                style: TextStyle(color: notifire.getdarkscolor),
                textAlign: TextAlign.start),
            borderRadius: 5,
          ).show(context);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error de red al subir la imagen: $e');
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> reloadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String newImagePath = prefs.getString("fcURLFotoPersonalizda") ?? '';
    setState(() {
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
    });
  }
}
