import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tareeqy_metro/Keys/Api_Keys.dart';
import 'package:tareeqy_metro/Payment/Services/PaymentService.dart';

class PaymobManager {
  Future<Map<String, dynamic>> _getPayment(int amount, String currency) async {
    try {
      String authenticationToken = await _getAuthenticationToken();
      print("hi: authentication token : " + authenticationToken);
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
      );

      return {
        'paymentKey': paymentKey,
        'orderId': orderId,
        'authKey': authenticationToken,
      };
    } catch (e) {
      print("Exc==========================================");
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
        "first_name": "Clifford",
        "last_name": "Nicolas",
        "email": "claudette09@exa.com",
        "phone_number": "+86(8)9135210487",
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
      print('hi: Starting getTransaction');

      // Step 1: Inquire transaction by orderId
      print('hi: Inquiry transaction by orderId: $orderId');
      Map<String, dynamic> inquiryResponse =
          await _inquireTransactionByOrderId(authToken, orderId);

      // Check if inquiry was successful
      if (!inquiryResponse['isSuccess']) {
        throw Exception('Failed to inquire transaction');
      }

      // Extract transactionId from inquiry response
      String transactionId = inquiryResponse['data']['id'].toString();
      print('hi: Extracted transactionId: $transactionId');

      // Step 2: Get transaction details using transactionId
      final url = Uri.parse('$baseUrl$transactionId?token=$authToken');
      print('hi: Sending request to: ${url.toString()}');
      final response = await _dio.get(
        url.toString(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Check response status code
      if (response.statusCode == 200) {
        print('hi: Successfully loaded transaction details');
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
      print('hi: Error occurred: $e inside the get transaction');
      throw Exception('Error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> _inquireTransactionByOrderId(
      String authToken, String orderId) async {
    try {
      print(
          'hi: Starting inquireTransactionByOrderId order id is $orderId and the auth token is $authToken');

      final Response response = await Dio().post(
        "https://accept.paymob.com/api/ecommerce/orders/transaction_inquiry",
        data: {
          "auth_token": authToken,
          "order_id": orderId,
        },
      );

      print('hi: Response: ${response.data}');

      if (response.statusCode == 200) {
        print('hi: Successful inquiry transaction');
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
      print('hi: Error occurred: $e inside the inquiry of transaction');
      throw Exception('Error occurred: $e');
    }
  }

  Future<void> navigateToPaymobView(
      BuildContext context, TextEditingController _amountController) async {
    try {
      int amount = int.parse(_amountController.text);
      Map<String, dynamic> paymentKeyResponse =
          await PaymobManager()._getPayment(
        amount,
        "EGP",
      );

      String _paymentKey = paymentKeyResponse['paymentKey'];
      String _orderId = paymentKeyResponse['orderId'].toString();
      String _authKey = paymentKeyResponse['authKey'];
      late InAppWebViewController webView;

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
                  webView = controller;
                },
                onProgressChanged:
                    (InAppWebViewController controller, int progress) {},
              ),
            );
          },
        ),
      );

      // After returning from web view, attempt to get transaction details
      try {
        Map<String, dynamic> transactionDetails =
            await PaymobManager()._getTransaction(_authKey, _orderId);
        if (transactionDetails['isSuccess']) {
          print("Transaction succeeded");
          PaymentService().addAmountToUserWallet(context, amount.toString());
        } else {
          print("Transaction failed");
        }
      } catch (e) {
        print('Error inquiring about the transaction: $e');
      }
    } catch (e) {
      log('Error launching Paymob URL: ${e.toString()}' as num);
    }
  }
}
