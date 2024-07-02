import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tareeqy_metro/Keys/Api_Keys.dart';
import 'package:tareeqy_metro/Payment/Services/PaymentService.dart';

class PaymobManager {
  Future<Map<String, dynamic>> _getPayment(
      int amount,
      String currency,
      String email,
      String firstName,
      String lastName,
      String phoneNumber) async {
    try {
      String authenticationToken = await _getAuthenticationToken();
      int orderId = await _getOrderId(
        authenticationToken: authenticationToken,
        amount: (100 * amount).toString(),
        currency: currency,
      );

      String paymentKey = await _getPaymentKey(
        authenticationToken: authenticationToken,
        amount: (100 * amount).toString(),
        currency: currency,
        orderId: orderId.toString(),
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      return {
        'paymentKey': paymentKey,
        'orderId': orderId,
        'authKey': authenticationToken,
      };
    } catch (e) {
      print(e.toString());
      throw Exception();
    }
  }

  Future<String> _getAuthenticationToken() async {
    final Response response =
        await Dio().post("https://accept.paymob.com/api/auth/tokens", data: {
      "api_key": ApiKeys.PaymobApiKey,
    });
    return response.data["token"];
  }

  Future<int> _getOrderId({
    required String authenticationToken,
    required String amount,
    required String currency,
  }) async {
    final Response response = await Dio()
        .post("https://accept.paymob.com/api/ecommerce/orders", data: {
      "auth_token": authenticationToken,
      "amount_cents": amount,
      "currency": currency,
      "delivery_needed": "false",
      "items": [],
    });
    return response.data["id"];
  }

  Future<String> _getPaymentKey({
    required String authenticationToken,
    required String orderId,
    required String amount,
    required String currency,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    final Response response = await Dio()
        .post("https://accept.paymob.com/api/acceptance/payment_keys", data: {
      "expiration": 3600,
      "auth_token": authenticationToken,
      "order_id": orderId,
      "integration_id": ApiKeys.PaymobIntegrationIDCard,
      "amount_cents": amount,
      "currency": currency,
      "billing_data": {
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone_number": phoneNumber,
        "apartment": "NA",
        "floor": "NA",
        "street": "NA",
        "building": "NA",
        "shipping_method": "NA",
        "postal_code": "NA",
        "city": "NA",
        "country": "NA",
        "state": "NA"
      },
    });
    return response.data["token"];
  }

  final String baseUrl =
      "https://accept.paymobsolutions.com/api/acceptance/transactions/";
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> _getTransaction(
      String authToken, String orderId) async {
    try {
      Map<String, dynamic> inquiryResponse =
          await _inquireTransactionByOrderId(authToken, orderId);

      if (!inquiryResponse['isSuccess']) {
        throw Exception('Failed to inquire transaction');
      }

      String transactionId = inquiryResponse['data']['id'].toString();

      final url = Uri.parse('$baseUrl$transactionId?token=$authToken');
      final response = await _dio.get(
        url.toString(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data;
        bool isSuccess = responseData['success'];
        return {
          'data': responseData,
          'isSuccess': isSuccess,
        };
      } else {
        throw Exception(
            'Failed to load transaction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> _inquireTransactionByOrderId(
      String authToken, String orderId) async {
    try {

      final Response response = await Dio().post(
        "https://accept.paymob.com/api/ecommerce/orders/transaction_inquiry",
        data: {
          "auth_token": authToken,
          "order_id": orderId,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data;
        bool isSuccess = responseData['success'];
        return {
          'data': responseData,
          'isSuccess': isSuccess,
        };
      } else {
        throw Exception(
            'Failed to inquire transaction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<void> navigateToPaymobView(
      BuildContext context,
      TextEditingController _amountController,
      String email,
      String firstName,
      String lastName,
      String phoneNumber) async {
    try {
      int amount = int.parse(_amountController.text);
      Map<String, dynamic> paymentKeyResponse = await PaymobManager()
          ._getPayment(amount, "EGP", email, firstName, lastName, phoneNumber);

      String _paymentKey = paymentKeyResponse['paymentKey'];
      String _orderId = paymentKeyResponse['orderId'].toString();
      String _authKey = paymentKeyResponse['authKey'];

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Payment"),
              ),
              body: InAppWebView(
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final url = navigationAction.request.url;

                  if (url.toString().contains(
                      "https://accept.paymob.com/api/acceptance/iframes/851752?payment_token=$_paymentKey")) {
                    return NavigationActionPolicy.CANCEL;
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                initialUrlRequest: URLRequest(
                    url: Uri.parse(
                        "https://accept.paymob.com/api/acceptance/iframes/851752?payment_token=$_paymentKey")),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useShouldOverrideUrlLoading: true,
                  ),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                },
                onLoadError: (controller, url, code, message) {
                  print('WebView load error: $message');
                },
                onLoadHttpError: (controller, url, statusCode, description) {
                  print('WebView HTTP error: $statusCode - $description');
                },
                onProgressChanged: (controller, progress) {
                },
              ),
            );
          },
        ),
      );

      try {
        showProgressScreen(context);
        Map<String, dynamic> transactionDetails =
            await PaymobManager()._getTransaction(_authKey, _orderId);

        if (transactionDetails['isSuccess']) {
          PaymentService().addAmountToUserWallet(context, amount.toString());
        } 
      } catch (e) {
        print('Error inquiring about the transaction: $e');
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error launching Paymob URL: ${e.toString()}');
    }
  }

  void showProgressScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Loading..."),
            ],
          ),
        );
      },
    );
  }

  void hideProgressScreen(BuildContext context) {
    Navigator.pop(context);
  }
}
