import 'package:flutter/material.dart';
import 'package:tareeqy_metro/QR-Code/QR-service.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';

class numberOfStaionsQR extends StatefulWidget {
  const numberOfStaionsQR({super.key});

  @override
  State<numberOfStaionsQR> createState() => _numberOfStaionsQRState();
}

class _numberOfStaionsQRState extends State<numberOfStaionsQR> {
  String dropdownValue = '15 egp'; // Default dropdown value
  TextEditingController controller = TextEditingController();
  int number = 0;
  bool isButtonDisabled = true;
  final QRservices _qrServices =
      QRservices(); // Create an instance of the service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Number Of Stations Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //here must be a text box that takes only numbers and the number must be less than 80
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Stations',
              ),
              onChanged: (value) {
                setState(() {
                  number =
                      int.tryParse(value) ?? 0; // Update the number variable
                  isButtonDisabled = number <= 0 || number > 80;
                });
              },
            ),
            const SizedBox(
                height: 20), // Add some space between the dropdown and button
            ElevatedButton(
              onPressed: isButtonDisabled
                  ? null
                  : () async {
                      print(number);
                      String docId = await _qrServices.addQRWithStationsNu(
                          context, number);
                      if (docId.isNotEmpty) {
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
