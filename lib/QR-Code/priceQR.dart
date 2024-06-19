import 'package:flutter/material.dart';
import 'package:tareeqy_metro/QR-Code/QR-service.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';

class PriceQR extends StatefulWidget {
  const PriceQR({Key? key}) : super(key: key);

  @override
  State<PriceQR> createState() => _PriceQRState();
}

class _PriceQRState extends State<PriceQR> {
  String dropdownValue = '15 egp'; // Default dropdown value
  TextEditingController controller = TextEditingController();
  final QRservices _qrServices =
      QRservices(); // Create an instance of the service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF073042),
        title: const Text(
          "Get a Ticket",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 143, 143, 143),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButton<String>(
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
            ),
            const SizedBox(
                height: 20), // Add space between the dropdown and button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                foregroundColor: Colors.white,
              ),
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
                  await _qrServices.addQRCodeToUser(context, docId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRcode(qrData: docId),
                    ),
                  );
                }
              },
              child: const Text(
                'Get The Ticket',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
