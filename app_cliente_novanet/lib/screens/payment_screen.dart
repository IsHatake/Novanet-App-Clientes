// ignore_for_file: empty_catches

import 'dart:convert';

import 'package:app_cliente_novanet/service/payment_service.dart';
import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:pixelpay_sdk/models/item.dart' as pixelpay;
import 'package:pixelpay_sdk/models/order.dart' as pixelpay;
import 'package:pixelpay_sdk/models/settings.dart' as pixelpay;
import 'package:pixelpay_sdk/models/card.dart' as pixelpay;
import 'package:pixelpay_sdk/models/billing.dart' as pixelpay;
import 'package:pixelpay_sdk/entities/transaction_result.dart' as pixelpay;
import 'package:pixelpay_sdk/requests/sale_transaction.dart' as pixelpay;
import 'package:pixelpay_sdk/services/transaction.dart' as pixelpay;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  final String keyId;

  const PaymentScreen({Key? key, required this.keyId}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFlipped = false;

  late ColorNotifire notifire;
  int activeStep = 0;
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardholderController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController billingPhoneController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController nombrecliente = TextEditingController();
  final TextEditingController descripciondebito = TextEditingController();
  final TextEditingController billingAddressController =
      TextEditingController();

  bool termsAccepted = false;

  String selectedMonth = '';
  String selectedYear = '';

  double totalAmount = 0.0;
  String currency = "HNL";

  final int currentYear = DateTime.now().year;
  final int currentMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    getData();
    selectedYear = currentYear.toString();
    selectedMonth = currentMonth.toString().padLeft(2, '0');
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> ddl = [];
  List<Map<String, dynamic>> selectedItems = [];

  void getData() async {
    try {
      PagoService pagoService = PagoService();

      List<Map<String, dynamic>> data =
          await pagoService.getDataClient(widget.keyId);
      List<Map<String, dynamic>> generatedDDL =
          await pagoService.prestamosDDL(data);

      setState(() {
        ddl = generatedDDL;
        selectedItems = generatedDDL;
        nombrecliente.text = (data[0]['fcNombre'] ?? '');
        emailController.text =
            data.isNotEmpty ? (data[0]['fcCorreo'] ?? '') : '';
        billingPhoneController.text =
            data.isNotEmpty ? (data[0]['fcTelefono'] ?? '') : '';
        billingAddressController.text =
            data.isNotEmpty ? (data[0]['fcDireccionDetallada'] ?? '') : '';
        addressController.text =
            data.isNotEmpty ? (data[0]['fcDireccionDetallada'] ?? '') : '';
        phoneController.text =
            data.isNotEmpty ? (data[0]['fcTelefono'] ?? '') : '';
        descripciondebito.text = 'Paquete de Internet Novanet';
      });
      handleSetChangeData(selectedItems);
    } catch (error) {
      print('Error obteniendo datos: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error obteniendo datos del cliente')),
      );
    }
  }

  void handleSetChangeData(List<Map<String, dynamic>>? newValue) {
    if (newValue != null && newValue.isNotEmpty) {
      double total = newValue.fold(
        0.0,
        (accumulator, currentValue) {
          Map<String, dynamic> valueMap = jsonDecode(currentValue['value']);
          double value = double.tryParse(
                  valueMap['fnValorCuotaMonedaNacional']?.toString() ?? '0') ??
              0.0;
          double updatedAccumulator = accumulator + value;
          return updatedAccumulator;
        },
      );

      double totalD = newValue.fold(
        0.0,
        (accumulator, currentValue) {
          Map<String, dynamic> valueMap = jsonDecode(currentValue['value']);
          double value =
              double.tryParse(valueMap['fnValorCuota']?.toString() ?? '0') ??
                  0.0;
          double updatedAccumulator = accumulator + value;
          return updatedAccumulator;
        },
      );

      setState(() {
        selectedItems = newValue;
        totalAmount = total;
      });

      print('Total calculado [fnValorCuotaMonedaNacional]: $total');
      print('Total calculado [fnValorCuota]: $totalD');
    } else {
      setState(() {
        selectedItems = [];
        totalAmount = 0.0;
      });
    }
  }

  void _flipCard() {
    if (isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  Future<void> _processTransaction() async {
    if (!termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debe aceptar los términos para continuar.')),
      );
      return;
    }

    try {
      final settings = pixelpay.Settings();

      settings.setupEndpoint("https://hn.ficoposonline.com");
      settings.setupCredentials(
          "FH1059496235", "c32c713735c9f8c441ffaa616f8fe0a0");

      final card = pixelpay.Card();
      card.number = cardNumberController.text;
      card.cvv2 = cvvController.text;
      card.expire_month = int.parse(selectedMonth);
      card.expire_year = int.parse(selectedYear);
      card.cardholder = cardholderController.text;

      final billing = pixelpay.Billing();
      billing.address = billingAddressController.text;
      billing.country = "HN";
      billing.state = "HN-CR";
      billing.city = "San Pedro Sula";
      billing.phone = billingPhoneController.text;

      final item = pixelpay.Item();
      item.code = "00001";
      item.title = descripciondebito.text;
      item.price = totalAmount;
      item.qty = 1;

      final orderID = selectedItems
          .map((item) => jsonDecode(item['value'])['fcIDPrestamo'].toString())
          .join("-");
      final order = pixelpay.Order();
      order.id = orderID;
      order.currency = currency;
      order.customer_name = nombrecliente.text;
      order.customer_email = emailController.text;
      order.addItem(item);

      final sale = pixelpay.SaleTransaction();
      sale.setOrder(order);
      sale.setCard(card);
      sale.setBilling(billing);
      sale.authentication_identifier = orderID;
      // ..payment_uuid = const Uuid().v4()

      final transactionService = pixelpay.Transaction(settings);
      final response = await transactionService.doSale(sale);
      final statusCode = response!.getStatus();
      switch (statusCode) {
        case 200:
          CherryToast.success(
            backgroundColor: notifire.getbackcolor,
            title: Text(
              '${response.message}',
              style: TextStyle(color: notifire.getdarkscolor),
              textAlign: TextAlign.start,
            ),
            borderRadius: 5,
          ).show(context);
          handleContinue();
          await abono(response.message ?? '', jsonEncode(response.data),
              "${response.data!["transaction_auth"]}");

          await logTransaction(
              response.message ?? '', jsonEncode(response), orderID);

          break;

        // --------------------------------------------------------------------

        case 400:
        case 401:
        case 412:
        case 418:
        case 422:
        case 500:
          CherryToast.error(
            backgroundColor: notifire.getbackcolor,
            title: Text(
              '${response.message}',
              style: TextStyle(color: notifire.getdarkscolor),
              textAlign: TextAlign.start,
            ),
            borderRadius: 5,
          ).show(context);

          await logTransaction(
              response.message ?? '', jsonEncode(response), orderID);
          break;

        // --------------------------------------------------------------------

        case 402:
          CherryToast.warning(
            backgroundColor: notifire.getbackcolor,
            title: Text(
              '${response.message}',
              style: TextStyle(color: notifire.getdarkscolor),
              textAlign: TextAlign.start,
            ),
            borderRadius: 5,
          ).show(context);
          await logTransaction(
              response.message ?? '', jsonEncode(response), orderID);
          break;

        // --------------------------------------------------------------------

        case 408:
          CherryToast.warning(
            backgroundColor: notifire.getbackcolor,
            title: Text(
              '${response.message}',
              style: TextStyle(color: notifire.getdarkscolor),
              textAlign: TextAlign.start,
            ),
            borderRadius: 5,
          ).show(context);
          await logTransaction(
              response.message ?? '', jsonEncode(response), orderID);
          break;

        default:
          if (response.getStatus()! > 500) {
            CherryToast.error(
              backgroundColor: notifire.getbackcolor,
              title: Text(
                '${response.message}',
                style: TextStyle(color: notifire.getdarkscolor),
                textAlign: TextAlign.start,
              ),
              borderRadius: 5,
            ).show(context);
          }
          await logTransaction(
              response.message ?? '', jsonEncode(response), orderID);
          break;
      }

      if (pixelpay.TransactionResult.validateResponse(response!)) {
        final result = pixelpay.TransactionResult.fromResponse(response);

        final isValidPayment = transactionService.verifyPaymentHash(
            result.payment_hash ?? '', sale.order_id ?? '', "InternetNovanet");

        if (isValidPayment) {
          // SUCCESS Valid Payment
        } else {
          // ERROR
        }
      } else {
        // ERROR
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error procesando la transacción: $e')),
      );
    }
  }

  Future<String> getIPAddress() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ip'] ?? '';
      } else {
        print('Error al obtener la IP: ${response.statusCode}');
        return '';
      }
    } catch (error) {
      print('Error al obtener la IP: $error');
      return '';
    }
  }

  Future<void> abono(
      String message, String responseData, String transactionAuth) async {
    try {
      final pcIP = await getIPAddress();

      for (final item in selectedItems) {
        final data = {
          "piIDApp": 118,
          "piIDUsuario": 337,
          "pcIP": pcIP,
          "pcIdentidad": item['fcIdentidad'],
          "pnValordelAbono": item['fnValorCuota'] ?? 0.00,
          "pcIDPrestamo": item['fcIDPrestamo'],
          "pcComentarioAdicional": message,
          "pcReferencia": transactionAuth,
          "piIDTransaccion": '',
          "pcRespuestaPOS": responseData,
        };

        PagoService pagoService = PagoService();
        await pagoService.abono(data);
      }
    } catch (error) {}
  }

  Future<void> logTransaction(
      String message, String responseData, String orderId) async {
    try {
      final log = {
        "Pago": orderId,
        "Descripciondebito": "Paquete de Internet",
        "Cliente": nombrecliente.text ?? '',
        "TotalPago": totalAmount ?? 0.00,
        "RespuestaApi": responseData,
        "Comentario": message,
      };

      PagoService pagoService = PagoService();
      await pagoService.log(log);
    } catch (error) {}
  }

  void handleContinue() {
    setState(() {
      activeStep++;
    });
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      backgroundColor: notifire.getbackcolor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Pago de Servicios',
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
      body: Card(
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stepper(
                type: StepperType.vertical, // Cambiar a diseño vertical

                currentStep: activeStep,
                onStepContinue: () {
                  if (_formKeys[activeStep].currentState?.validate() ?? false) {
                    if (activeStep < 2) {
                      setState(() {
                        activeStep++;
                      });
                    } else {
                      _processPayment();
                    }
                  }
                },
                onStepCancel: () {
                  if (activeStep > 0) {
                    setState(() {
                      activeStep--;
                    });
                  }
                },
                steps: [
                  Step(
                    title: const Text("Confirmación"),
                    content: Column(
                      children: [
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Pago de Servicios",
                                style: TextStyle(
                                  fontSize: 21.0,
                                  fontWeight: FontWeight.bold,
                                  color: notifire.getprimerycolor,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                nombrecliente.text,
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Seleccione los servicios a pagar",
                          style: TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        DropdownSearch<Map<String, dynamic>>.multiSelection(
                          items: ddl,
                          selectedItems: selectedItems,
                          itemAsString: (item) => "${item['label']}",
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Servicios",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          onChanged:
                              (List<Map<String, dynamic>>? selectedList) {
                            handleSetChangeData(selectedList);
                          },
                          dropdownBuilder: (context, selectedItems) {
                            return Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: selectedItems.map((item) {
                                return Chip(
                                  backgroundColor: Colors.grey[200],
                                  label: Text(
                                    "${item['label']}",
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 18.0,
                                    color: Colors.black54,
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      selectedItems.remove(item);
                                      handleSetChangeData(selectedItems);
                                    });
                                  },
                                );
                              }).toList(),
                            );
                          },
                          popupProps: PopupPropsMultiSelection.menu(
                            itemBuilder: (context, item, isSelected) {
                              return ListTile(
                                selected: isSelected,
                                title: Text("${item['label']}"),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Image.asset(
                          "images/NOVANETLOGO.png",
                          width: 200,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300], // Color de la línea
                                thickness: 1, // Grosor de la línea
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Chip(
                                label: Text(
                                  "Confirmación",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black45,
                                  ),
                                ),
                                backgroundColor:
                                    Color.fromARGB(255, 214, 214, 214),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300], // Color de la línea
                                thickness: 1, // Grosor de la línea
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Verifique que el monto sea correcto",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Usted realizará un pago\npor un total de",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "L $totalAmount",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Checkbox(
                              value: termsAccepted,
                              activeColor: notifire.getorangeprimerycolor,
                              onChanged: (value) {
                                setState(() {
                                  termsAccepted = value!;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                "Confirmo y Acepto el monto",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: notifire.getorangeprimerycolor,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: termsAccepted
                              ? () {
                                  if (activeStep < 2) {
                                    setState(() {
                                      activeStep++;
                                    });
                                  }
                                }
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "CONTINUAR",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8.0),
                              Icon(Icons.arrow_forward, size: 18.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Step(
                    title: const Text("Detalles de Facturación"),
                    content: Form(
                      key: _formKeys[1],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isFlipped = !isFlipped;
                              });
                            },
                            child: Center(
                              child: GestureDetector(
                                onTap: _flipCard,
                                child: AnimatedBuilder(
                                  animation: _animation,
                                  builder: (context, child) {
                                    final angle = _animation.value *
                                        pi; // Rotación en radianes
                                    return Transform(
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001) // Perspectiva
                                        ..rotateY(angle),
                                      alignment: Alignment.center,
                                      child: angle <= pi / 2
                                          ? _buildCardFront()
                                          : Transform(
                                              transform: Matrix4.identity()
                                                ..rotateY(pi),
                                              alignment: Alignment.center,
                                              child: _buildCardBack(),
                                            ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: cardNumberController,
                            label: "Número de tarjeta *",
                            icon: Icons.credit_card,
                            inputType: TextInputType.number,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: cardholderController,
                            label: "Nombre del Titular de la Tarjeta *",
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: emailController,
                            label: "Correo electrónico *",
                            icon: Icons.email,
                            inputType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: phoneController,
                            label: "Teléfono *",
                            icon: Icons.phone,
                            inputType: TextInputType.phone,
                          ),
                          const SizedBox(height: 15),
                          _buildTextArea(
                            controller: addressController,
                            label: "Dirección *",
                            icon: Icons.location_on,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Flexible(
                                child: DropdownButtonFormField<String>(
                                  value: selectedMonth,
                                  items: _getAvailableMonths(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedMonth = value!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "Mes *",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? "Requerido"
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: DropdownButtonFormField<String>(
                                  value: selectedYear,
                                  items: _getAvailableYears(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedYear = value!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "Año *",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? "Requerido"
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: _buildTextField(
                                  controller: cvvController,
                                  label: "CVV2 *",
                                  inputType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      if (activeStep > 0) {
                                        activeStep--;
                                        for (var formKey in _formKeys) {
                                          formKey.currentState?.reset();
                                        }
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text("REGRESAR"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() async {
                                      if (_formKeys[activeStep]
                                              .currentState
                                              ?.validate() ??
                                          false) {
                                        if (activeStep < 2) {
                                          await _processTransaction();
                                        }
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text("CONTINUAR"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        notifire.getorangeprimerycolor,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Step(
                    title: const Text("Finalización"),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icono de éxito
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[700],
                          size: 70,
                        ),
                        const SizedBox(height: 16),
                        // Texto de título
                        const Text(
                          "Pago Exitoso",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "¡Tu pago ha sido procesado con éxito!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedItems.isNotEmpty)
                                _buildDetailRow(
                                  "Nro. Facturas:",
                                  selectedItems.map((item) {
                                    final decodedValue =
                                        jsonDecode(item['value']);
                                    return decodedValue['fcIDPrestamo']
                                        .toString();
                                  }).join("-"),
                                ),
                              const SizedBox(height: 8),
                              _buildDetailRow("Descripción Débito:",
                                  descripciondebito.text),
                              const SizedBox(height: 8),
                              _buildDetailRow("Cliente:", nombrecliente.text),
                              const SizedBox(height: 8),
                              _buildDetailRow("Correo:", emailController.text),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                  "Dirección:", addressController.text),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                  "Teléfono:", phoneController.text),
                              const SizedBox(height: 8),
                              _buildDetailRow("Total:", "$totalAmount HNL"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                controlsBuilder:
                    (BuildContext context, ControlsDetails details) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 110,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        image: DecorationImage(
          image: AssetImage("images/novanet.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    if (!termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debe aceptar los términos para continuar.')),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Pago realizado con éxito!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error procesando el pago.')),
      );
    }
  }

  List<DropdownMenuItem<String>> _getAvailableMonths() {
    int startMonth =
        (selectedYear == currentYear.toString()) ? currentMonth : 1;
    return List.generate(
      12 - startMonth + 1,
      (index) => DropdownMenuItem(
        value: (startMonth + index).toString().padLeft(2, '0'),
        child: Text((startMonth + index).toString().padLeft(2, '0')),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getAvailableYears() {
    return List.generate(
      20,
      (index) => DropdownMenuItem(
        value: (currentYear + index).toString(),
        child: Text((currentYear + index).toString()),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      width: 350,
      height: 180,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage("images/card_bg.png"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Imagen del chip
            Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                "images/chip2.png",
                width: 50,
                height: 40,
              ),
            ),
            // Número de tarjeta
            Center(
              child: Text(
                cardNumberController.text.isNotEmpty
                    ? cardNumberController.text
                        .replaceAllMapped(
                          RegExp(r".{4}"),
                          (match) => "${match.group(0)} ",
                        )
                        .trim()
                    : "**** **** **** ****",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            // Nombre del titular y fecha de expiración
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Contenedor flexible para el nombre del titular
                Flexible(
                  flex: 2,
                  child: Text(
                    cardholderController.text.isNotEmpty
                        ? cardholderController.text
                        : "NOMBRE COMPLETO",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis, // Trunca el texto con "..."
                  ),
                ),
                const SizedBox(width: 10), // Espaciado entre textos
                // Fecha de expiración
                Flexible(
                  flex: 1,
                  child: Text(
                    "${selectedMonth.isNotEmpty ? selectedMonth : 'MM'}/${selectedYear.isNotEmpty ? selectedYear : 'YY'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: 350,
      height: 180,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage("images/card_bg.png"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 40,
              color: Colors.black,
              margin: const EdgeInsets.symmetric(vertical: 10),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "CVV ${cvvController.text.isNotEmpty ? cvvController.text : '***'}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {});
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Requerido';
        }
        return null;
      },
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {});
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Requerido';
        }
        return null;
      },
    );
  }
}

class CustomStepper extends StatelessWidget {
  final int currentStep;
  final List<Step> steps;
  final Function(int) onStepTapped;
  final Function() onStepContinue;
  final Function() onStepCancel;

  const CustomStepper({
    required this.currentStep,
    required this.steps,
    required this.onStepTapped,
    required this.onStepContinue,
    required this.onStepCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCurrentStep = index == currentStep;

        return Column(
          children: [
            GestureDetector(
              onTap: () => onStepTapped(index),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: isCurrentStep ? 16 : 12,
                    backgroundColor:
                        isCurrentStep ? Colors.orange : Colors.grey[300],
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCurrentStep ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: Colors.grey[300],
                      ),
                    ),
                ],
              ),
            ),
            if (isCurrentStep)
              Container(
                padding: const EdgeInsets.all(16.0),
                child: step.content,
              ),
          ],
        );
      }),
    );
  }
}
