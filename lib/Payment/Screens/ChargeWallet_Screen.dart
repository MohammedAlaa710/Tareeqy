import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:tareeqy_metro/Keys/Api_Keys.dart';
import 'package:tareeqy_metro/Payment/Models/amount_model/amount_model.dart';
import 'package:tareeqy_metro/Payment/Models/amount_model/details.dart';
import 'package:tareeqy_metro/Payment/Models/item_list_model/item.dart';
import 'package:tareeqy_metro/Payment/Models/item_list_model/item_list_model.dart';
import 'package:tareeqy_metro/Payment/Services/PaymentService.dart';
import 'package:tareeqy_metro/Profile/myProfile_Screen.dart';

class ChargeWalletScreen extends StatefulWidget {
  const ChargeWalletScreen({super.key});

  @override
  State<ChargeWalletScreen> createState() => _ChargeWalletScreenState();
}

class _ChargeWalletScreenState extends State<ChargeWalletScreen> {
  final TextEditingController _amountController = TextEditingController();

  void _showConfirmationDialog(double amount) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Charge'),
          content:
              Text('Are you sure you want to charge \$$amount to your wallet?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // PayPal blue color
              ),
              onPressed: () {
                var TransactionData = getTransactionsData(amount: amount);
                NavigateToPaypalView(context, TransactionData);
                
                // Handle the charge logic here
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void NavigateToPaypalView(BuildContext context, ({AmountModel Amount, ItemListModel itemslist}) TransactionData) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => PaypalCheckoutView(
        sandboxMode: true,
        clientId: ApiKeys.PaypalClientID,
        secretKey: ApiKeys.PaypalSecretKey,
        transactions:  [
          {
            "amount": TransactionData.Amount.toJson(),
            "description": "The payment transaction description.",
            // "payment_options": {
            //   "allowed_payment_method":
            //       "INSTANT_FUNDING_SOURCE"
            // },
            "item_list": TransactionData.itemslist.toJson(),
          }
        ],
        note: "Contact us for any questions on your order.",
        onSuccess: (Map params) async {
          log("onSuccess: $params");
          PaymentService().addAmountToUserWallet(context,TransactionData.Amount.total.toString());
          Navigator.pop(context);
          Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const myProfile_Screen(),
                                ),
                              );
        },
        onError: (error) {
          log("onError: $error");
          Navigator.pop(context);
        },
        onCancel: () {
          print('cancelled:');
          Navigator.pop(context);
        },
      ),
    ));
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        backgroundColor: Colors.white,
        title: const Text(
          'Charge Wallet',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter Amount to Charge',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 800.ms).slide(),
              const SizedBox(height: 20),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Amount',
                  hintText: 'Enter amount in USD',
                ),
              ).animate().fadeIn(duration: 800.ms).slide(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 255, 255, 255), // PayPal blue color
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Image.asset(
                  'assets/images/paypal.png',
                  height: 50,
                ),
                label: const Text(
                  'Pay with PayPal',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF003087),
                  ),
                ),
                onPressed: () {
                  double? amount = double.tryParse(_amountController.text);
                  if (amount != null && amount > 0) {
                    _showConfirmationDialog(amount);
                  } else {
                    // Show a warning if the amount is not valid
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Invalid Amount'),
                          content: const Text('Please enter a valid amount.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ).animate().fadeIn(duration: 800.ms).slide(),
            ],
          ),
        ),
      ),
    );
  }
  //Function for getting the transaction data to send it to paypal
({AmountModel Amount, ItemListModel itemslist})  getTransactionsData({ double? amount}){
          var amountModel = AmountModel(
                  total: amount.toString(),
                   currency: "USD" , 
                   details: Details(
                    shipping: "0" , 
                    shippingDiscount: 0 ,
                    subtotal: amount.toString())
                    );
                    List<Item> items = [
                                        Item(name: "Charge Tareeqy Wallet" , currency: "USD" , price: amount.toString() , quantity: 1),

                    ];
                    var itemList = ItemListModel(items: items); 
                    return( Amount : amountModel , itemslist : itemList);


  }

  }
