import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:tareeqy_metro/Keys/Api_Keys.dart';
import 'package:tareeqy_metro/Payment/Models/amount_model/amount_model.dart';
import 'package:tareeqy_metro/Payment/Models/amount_model/details.dart';
import 'package:tareeqy_metro/Payment/Models/item_list_model/item.dart';
import 'package:tareeqy_metro/Payment/Models/item_list_model/item_list_model.dart';
import 'package:tareeqy_metro/Payment/PaymobManager/PaymobManager.dart';
import 'package:tareeqy_metro/Payment/Services/PaymentService.dart';

class ChargeWalletScreen extends StatefulWidget {
  const ChargeWalletScreen({super.key});

  @override
  State<ChargeWalletScreen> createState() => _ChargeWalletScreenState();
}

class _ChargeWalletScreenState extends State<ChargeWalletScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedPaymentMethod;

  void _showConfirmationDialog(double amount, String paymentMethod) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Confirm Charge',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to charge \$${amount.toStringAsFixed(2)} to your wallet using $paymentMethod?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // PayPal blue color
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                if (_selectedPaymentMethod == 'PayPal') {
                  var transactionData = getTransactionsData(amount: amount);
                  navigateToPaypalView(context, transactionData);
                } else if (_selectedPaymentMethod == 'PayMob') {
                  navigateToPaymobView(context, _amountController);
                }
              },
              child: Text(
                'Confirm',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> navigateToPaymobView(
      BuildContext context, TextEditingController _amountController) async {
    setState(() {
      PaymobManager().navigateToPaymobView(context, _amountController);
    });
  }

  void navigateToPaypalView(BuildContext context,
      ({AmountModel amount, ItemListModel itemslist}) transactionData) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => PaypalCheckoutView(
        sandboxMode: true,
        clientId: ApiKeys.PaypalClientID,
        secretKey: ApiKeys.PaypalSecretKey,
        transactions: [
          {
            "amount": transactionData.amount.toJson(),
            "description": "The payment transaction description.",
            "item_list": transactionData.itemslist.toJson(),
          }
        ],
        note: "Contact us for any questions on your order.",
        onSuccess: (Map params) async {
          log("onSuccess: $params");
          PaymentService().addAmountToUserWallet(
              context, transactionData.amount.total.toString());
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
  void initState() {
    super.initState();
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
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'PayPal';
                      });
                    },
                    child: AnimatedContainer(
                      duration: 300.ms,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedPaymentMethod == 'PayPal'
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 255, 255, 255), // PayPal blue color
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
                          setState(() {
                            _selectedPaymentMethod = 'PayPal';
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'PayMob';
                      });
                    },
                    child: AnimatedContainer(
                      duration: 300.ms,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedPaymentMethod == 'PayMob'
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 255, 255, 255), // PayMob blue color
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(
                          Icons.payment,
                          color: Color(0xFF003087),
                          size: 50,
                        ),
                        label: const Text(
                          'Pay with Paymob',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF003087),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedPaymentMethod = 'PayMob';
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_selectedPaymentMethod != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Proceed button color
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        double? amount =
                            double.tryParse(_amountController.text);
                        if (amount != null && amount > 0) {
                          _showConfirmationDialog(
                              amount, _selectedPaymentMethod!);
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Invalid Amount'),
                                content:
                                    const Text('Please enter a valid amount.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: const Text(
                        'Proceed with Payment',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms).slide(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function for getting the transaction data to send it to PayPal
  ({AmountModel amount, ItemListModel itemslist}) getTransactionsData(
      {double? amount}) {
    var amountModel = AmountModel(
        total: amount.toString(),
        currency: "USD",
        details: Details(
            shipping: "0", shippingDiscount: 0, subtotal: amount.toString()));
    List<Item> items = [
      Item(
          name: "Charge Tareeqy Wallet",
          currency: "USD",
          price: amount.toString(),
          quantity: 1),
    ];
    var itemList = ItemListModel(items: items);
    return (amount: amountModel, itemslist: itemList);
  }
}
