// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:tareeqy_metro/QR-Code/QR-service.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';

class priceQR extends StatefulWidget {
  const priceQR({super.key});

  @override
  State<priceQR> createState() => _priceQRState();
}

class _priceQRState extends State<priceQR> {
  String dropdownValue = '15 egp'; // Default dropdown value
  TextEditingController controller = TextEditingController();
  final QRservices _qrServices =
      QRservices(); // Create an instance of the service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("price page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              value: dropdownValue,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                }
              },
              items: <String>['6 egp', '8 egp', '12 egp', '15 egp']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(
                height: 20), // Add some space between the dropdown and button
            ElevatedButton(
              onPressed: () async {
                int price;
                if (dropdownValue == '6 egp') {
                  price = 6;
                } else if (dropdownValue == '12 egp') {
                  price = 12;
                } else if (dropdownValue == '8 egp') {
                  price = 8;
                } else {
                  price = 15;
                }
                String docId =
                    await _qrServices.addQRWithPrice(context, '$price egp');
                if (docId.isNotEmpty) {
                  // ignore: use_build_context_synchronously
                  await _qrServices.addQRCodeToUser(context, docId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRcode(qrData: docId),
                    ),
                  );
                }
              },
              child: const Text('Add Document'),
            ),
          ],
        ),
      ),
    );
  }
}
