import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:credit_card_scanner/credit_card_scanner.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';

import 'package:pixelpay_sdk/requests/sale_transaction.dart' as pixelpay;
import 'package:pixelpay_sdk/models/order.dart' as pixelpay;
import 'package:pixelpay_sdk/models/settings.dart' as pixelpay;
import 'package:pixelpay_sdk/models/card.dart' as pixelpay;
import 'package:pixelpay_sdk/models/billing.dart' as pixelpay;
import 'package:pixelpay_sdk/entities/transaction_result.dart' as pixelpay;
import 'package:pixelpay_sdk/services/transaction.dart' as pixelpay;
import 'package:pixelpay_sdk/models/item.dart' as pixelpay;

class Scan extends StatefulWidget {
  const Scan({Key? key}) : super(key: key);

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  late ColorNotifire notifire;
  var anio = DateTime.now().year.toString().substring(2, 4);
  var month = DateTime.now().month.toString();

  Future<void> performSaleTransaction() async {
    try {
      final settings = pixelpay.Settings();

      settings.setupEndpoint("https://{endpoint}");
      settings.setupCredentials(
          "2222222222", "elhashmd5delsecretkeydelcomercio");

      List<String> dateParts = expiryDate.split('/');
      int month = int.parse(dateParts[0]);
      int year = int.parse(dateParts[1]);


      final card = pixelpay.Card();
      card.number = cardNumber;
      card.cvv2 = cvvCode;
      card.expire_month = month;
      card.expire_year = year;
      card.cardholder = cardHolderName;

      final billing = pixelpay.Billing();
      billing.address = "Ave Circunvalacion";
      billing.country = "HN";
      billing.state = "HN-CR";
      billing.city = "San Pedro Sula";
      billing.phone = "99999999";

      final item = pixelpay.Item();
      item.code = "00001";
      item.title = "Videojuego";
      item.price = 800;
      item.qty = 1;

      final order = pixelpay.Order();
      order.id = "ORDER-12948";
      order.currency = "HNL";
      order.customer_name = "SERGIO PEREZ";
      order.customer_email = "sergio.perez@gmail.com";
      order.addItem(item);

      final sale = pixelpay.SaleTransaction();
      sale.setOrder(order);
      sale.setCard(card);
      sale.setBilling(billing);

      final service = pixelpay.Transaction(settings);
      final response = await service.doSale(sale);

      if (pixelpay.TransactionResult.validateResponse(response!)) {
        final result = pixelpay.TransactionResult.fromResponse(response);

        final isValidPayment = service.verifyPaymentHash(
            result.payment_hash.toString(), sale.order_id.toString(), "abc...");

        if (isValidPayment) {
          CherryToast.success(
            backgroundColor: notifire.getbackcolor,
            title: Text(
              'Pago completado exitosamente',
              style: TextStyle(color: notifire.getdarkscolor),
              textAlign: TextAlign.start,
            ),
            borderRadius: 5,
          ).show(context);
        } else {
          CherryToast.error(
            backgroundColor: notifire.getbackcolor,
            title: Text(
              'Error en la validación del pago',
              style: TextStyle(color: notifire.getdarkscolor),
              textAlign: TextAlign.start,
            ),
            borderRadius: 5,
          ).show(context);
        }
      } else {
        CherryToast.error(
          backgroundColor: notifire.getbackcolor,
          title: Text(
            'Error en la validación del pago',
            style: TextStyle(color: notifire.getdarkscolor),
            textAlign: TextAlign.start,
          ),
          borderRadius: 5,
        ).show(context);
      }
    } catch (e) {
      CherryToast.error(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'Error al realizar el pago',
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
    }
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

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController cardNumberController = TextEditingController();

  final maskFormatter = MaskTextInputFormatter(
    mask: '#### #### #### ####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  CardScanOptions scanOptions = const CardScanOptions(
    scanCardHolderName: true,
    validCardsToScanBeforeFinishingScan: 5,
    possibleCardHolderNamePositions: [
      CardHolderNameScanPosition.aboveCardNumber,
    ],
  );

  @override
  void initState() {
    super.initState();
    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Realizar Pago de Servicio',
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
      resizeToAvoidBottomInset: false,
      backgroundColor: notifire.getwhite,
      body: Container(
        decoration: BoxDecoration(
          image: !useBackgroundImage
              ? const DecorationImage(
                  image: ExactAssetImage('images/bg.png'),
                  fit: BoxFit.fill,
                )
              : null,
          color: notifire.getprimerycolor,
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              CreditCardWidget(
                width: 420,
                height: 240,
                labelCardHolder: 'Brooklyn Simmons',
                labelExpiredDate:
                    '${month.length == 1 ? '0$month' : month} / $anio',
                labelValidThru: 'Exp.',
                chipColor: Colors.grey,
                glassmorphismConfig:
                    useGlassMorphism ? Glassmorphism.defaultConfig() : null,
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                bankName: ' ',
                showBackView: isCvvFocused,
                obscureCardNumber: false,
                obscureCardCvv: false,
                isHolderNameVisible: true,
                cardBgColor: Colors.black,
                backgroundImage: 'images/card_bg.png',
                isSwipeGestureEnabled: true,
                onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                customCardTypeIcons: <CustomCardTypeIcon>[
                  CustomCardTypeIcon(
                    cardType: CardType.mastercard,
                    cardImage: Image.asset(
                      'images/mastercard.png',
                      height: 48,
                      width: 48,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      CreditCardForm(
                        formKey: formKey,
                        cardNumber: cardNumber,
                        cvvCode: cvvCode,
                        isHolderNameVisible: true,
                        isCardNumberVisible: true,
                        isExpiryDateVisible: true,
                        cardHolderName: cardHolderName,
                        expiryDate: expiryDate,
                        themeColor: Colors.orange,
                        textColor: notifire.getdarkscolor,
                        cardHolderDecoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: notifire.getorangeprimerycolor)),
                          hintStyle: const TextStyle(color: Colors.black),
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: border,
                          enabledBorder: border,
                          labelText: 'Nombre de Titular',
                        ),
                        cardNumberDecoration: InputDecoration(
                          labelText: 'Número de Tarjeta',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: notifire.getorangeprimerycolor)),
                          hintStyle: const TextStyle(color: Colors.black),
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: border,
                          enabledBorder: border,
                        ),
                        expiryDateDecoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: notifire.getorangeprimerycolor)),
                          hintStyle: const TextStyle(color: Colors.black),
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: border,
                          enabledBorder: border,
                          labelText: 'Fecha Exp.',
                          hintText: 'XX/XX',
                        ),
                        cvvCodeDecoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: notifire.getorangeprimerycolor)),
                          hintStyle: const TextStyle(color: Colors.black),
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: border,
                          enabledBorder: border,
                          labelText: 'CVV',
                          hintText: 'XXX',
                        ),
                        onCreditCardModelChange: onCreditCardModelChange,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: notifire.getorangeprimerycolor,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            performSaleTransaction();
                          } else {
                            if (kDebugMode) {
                              print('Formulario inválido!');
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Procesar pago',
                            style: TextStyle(
                              color: notifire.getwhite,
                              fontFamily: 'Gilroy Bold',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
