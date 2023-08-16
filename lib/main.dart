import 'dart:developer';

import 'package:easy_paypal/easy_paypal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

String clientId = 'YOUR_CLIENT_ID';
String secretKey = 'YOUR_SECRET_KEY';


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PayPal Test'),),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(onPressed: (){
              onPayPalClickEasyPayPal(context);
            }, child: Text('Easy PayPal')),
          ),
          Center(
            child: ElevatedButton(onPressed: (){
              onFlutterPayPalCheckout(context);
            }, child: Text('Flutter PayPal Checkout')),
          ),
          Center(
            child: ElevatedButton(onPressed: (){
              onFlutterPayPal(context);
            }, child: Text('Flutter PayPal')),
          ),
        ],
      ),
    );
  }

  Future<void> onPayPalClickEasyPayPal(BuildContext context) async {
    final _easyPaypalPlugin = EasyPaypal();
    var order = const PPOrder(
      intent: PPOrderIntent.capture,
      appContext: PPOrderAppContext(
        brandName: 'Comped',
        shippingPreference: PPShippingPreference.noShipping,
        userAction: PPUserAction.payNowAction,
      ),
      purchaseUnitList: [
        PPPurchaseUnit(
          referenceId: 'test',
          shipping: PPShipping(
            address: PPOrderAddress(
              addressLine1: '123 Main St',
              adminArea1: 'TX',
              adminArea2: 'Austin',
              postalCode: '78751',
              countryCode: 'US',
            ),
          ),
          orderAmount: PPOrderAmount(
            currencyCode: PPCurrencyCode.usd,
            value: '0.02',
          ),
        ),
      ],
    );

    try{
      _easyPaypalPlugin.initConfig(
          config:  PPCheckoutConfig(
            clientId: clientId,
            environment: PPEnvironment.live,
            returnUrl: 'nativexo://paypalpay',
          ));

      _easyPaypalPlugin.setCallback(PPCheckoutCallback(onApprove: (data) {
        _showAlertDialog(context, 'Success');
        log('Success:${data.toJson()}');
      }, onError: (data) {
        _showAlertDialog(context, 'Error: ${data.reason}');
        log('Error: ${data.toJson()}');
      }, onCancel: () {
        _showAlertDialog(context, 'Canceled');
        log('cancelled');
      }));
    }catch(e){
      log(e.toString());
    }

    _easyPaypalPlugin.checkout(order: order);

  }

  Future<void> onFlutterPayPalCheckout(BuildContext context) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext cxt) => PaypalCheckout(
        sandboxMode: false,
        clientId: clientId,
        secretKey: secretKey,
        returnURL: "com.tenfins.paypal.flutter_paypal_test",
        cancelURL: "com.tenfins.paypal.flutter_paypal_test",
        transactions: const [
          {
            "amount": {
              "total": '0.02',
              "currency": "USD",
              "details": {
                "subtotal": '0.02',
                "shipping": '0',
                "shipping_discount": 0
              }
            },
            "description": "The payment transaction description.",
            "item_list": {
              "items": [

              ],
            }
          }
        ],
        note: "Contact us for any questions on your order.",
        onSuccess: (Map params) async {
          _showAlertDialog(context, 'Success');
          print("onSuccess: $params");
        },
        onError: (error) {
          _showAlertDialog(context, 'Error: $error');
          print("onError: $error");
        },
        onCancel: () {
          _showAlertDialog(context, 'Cancelled');
          print('cancelled:');
        },
      ),
    ));
  }

  Future<void> onFlutterPayPal(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext cxt) => UsePaypal(
            sandboxMode: false,
            clientId: clientId,
            secretKey: secretKey,
            returnURL: "com.tenfins.paypal.flutter_paypal_test.payments",
            cancelURL: "com.tenfins.paypal.flutter_paypal_test.payments",
            transactions: const [
              {
                "amount": {
                  "total": '0.02',
                  "currency": "USD",
                  "details": {
                    "subtotal": '0.02',
                    "shipping": '0',
                    "shipping_discount": 0
                  }
                },
                "description": "The payment transaction description.",
                "item_list": {
                  "items": [

                  ],

                  // shipping address is not required though
                  "shipping_address": {
                    "recipient_name": "Jane Foster",
                    "line1": "Travis County",
                    "line2": "",
                    "city": "Austin",
                    "country_code": "US",
                    "postal_code": "73301",
                    "phone": "+00000000",
                    "state": "Texas"
                  },
                }
              }
            ],
            note: "Contact us for any questions on your order.",
          onSuccess: (Map params) async {
            _showAlertDialog(context, 'Success');
            print("onSuccess: $params");
          },
          onError: (error) {
            _showAlertDialog(context, 'Error: $error');
            print("onError: $error");
          },
          onCancel: () {
            _showAlertDialog(context, 'Cancelled');
            print('cancelled:');
          },
      ),
    ));
  }

  Future<void> _showAlertDialog(BuildContext context, String data) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('PayPal Status'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(data),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
