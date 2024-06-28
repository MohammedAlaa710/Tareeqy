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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  void _showConfirmationDialog(double amount, String paymentMethod) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Confirm Charge',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF073042)),
          ),
          content: Text(
            'Are you sure you want to charge \$${amount.toStringAsFixed(2)} to your wallet using $paymentMethod?',
            style: const TextStyle(fontSize: 16, color: Color(0xFF073042)),
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
                backgroundColor: const Color(0xFF00796B),
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
                  if (_formKey.currentState?.validate() ?? false) {
                    navigateToPaymobView1(
                      context,
                      _amountController,
                      _emailController.text,
                      _firstNameController.text,
                      _lastNameController.text,
                      _phoneNumberController.text,
                    );
                  }
                }
              },
              child: const Text(
                'Confirm',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> navigateToPaymobView1(
    BuildContext context,
    TextEditingController _amountController,
    String email,
    String firstName,
    String lastName,
    String phoneNumber,
  ) async {
    try {
      await PaymobManager().navigateToPaymobView(
        context,
        _amountController,
        email,
        firstName,
        lastName,
        phoneNumber,
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Payment Error',
                style: TextStyle(color: Color(0xFF073042))),
            content: Text(
              'An error occurred during the payment process: $error',
              style: const TextStyle(color: Color(0xFF073042)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK', style: TextStyle(color: Color(0xFF00796B))),
              ),
            ],
          );
        },
      );
    }
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

  void _showMissingFieldsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Missing Fields',
              style: TextStyle(color: Color(0xFF073042))),
          content: const Text(
            'Please fill out all required fields before proceeding.',
            style: TextStyle(color: Color(0xFF073042)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Color(0xFF00796B))),
            ),
          ],
        );
      },
    );
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
        backgroundColor: const Color(0xFF073042),
        title: const Text(
          'Charge Wallet',
          style: TextStyle(
            color: Colors.white,
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
                      color: Color(0xFF073042),
                    ),
                  ).animate().fadeIn(duration: 800.ms).slide(),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Amount',
                      hintText: 'Enter amount',
                      labelStyle: const TextStyle(color: Color(0xFF073042)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF00796B)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ).animate().fadeIn(duration: 800.ms).slide(),
                  const SizedBox(height: 20),
                  if (_selectedPaymentMethod == 'PayMob') ...[
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              labelStyle: const TextStyle(color: Color(0xFF073042)),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xFF00796B)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'First Name',
                              hintText: 'Enter your first name',
                              labelStyle: const TextStyle(color: Color(0xFF073042)),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xFF00796B)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Last Name',
                              hintText: 'Enter your last name',
                              labelStyle: const TextStyle(color: Color(0xFF073042)),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xFF00796B)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Phone Number',
                              hintText: 'Enter your phone number',
                              labelStyle: const TextStyle(color: Color(0xFF073042)),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xFF00796B)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
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
                              ? const Color(0xFF00796B)
                              : const Color.fromARGB(255, 230, 230, 230),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Image.asset(
                          'assets/images/paypal.png',
                          height: 70,
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
                              ? const Color(0xFF00796B)
                              : const Color.fromARGB(255, 230, 230, 230),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Image.asset(
                          'assets/images/paymob_back.png',
                          height: 80,
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
                        backgroundColor: const Color(0xFF00796B),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        double? amount =
                            double.tryParse(_amountController.text);
                        if (_selectedPaymentMethod == 'PayMob' &&
                            !_formKey.currentState!.validate()) {
                          _showMissingFieldsDialog();
                          return;
                        }
                        if (amount != null && amount > 0) {
                          _showConfirmationDialog(
                              amount, _selectedPaymentMethod!);
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                title: const Text('Invalid Amount',
                                    style: TextStyle(color: Color(0xFF073042))),
                                content: const Text(
                                    'Please enter a valid amount.',
                                    style: TextStyle(color: Color(0xFF073042))),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('OK',
                                        style: TextStyle(
                                            color: Color(0xFF00796B))),
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
                    ).animate().fadeIn(duration: 400.ms).slide(),
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
