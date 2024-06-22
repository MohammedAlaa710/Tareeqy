import 'package:flutter/material.dart';
import 'package:tareeqy_metro/QR-Code/QR-service.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';

class NumberOfStationsQR extends StatefulWidget {
  const NumberOfStationsQR({Key? key}) : super(key: key);

  @override
  State<NumberOfStationsQR> createState() => _NumberOfStationsQRState();
}

class _NumberOfStationsQRState extends State<NumberOfStationsQR> {
  TextEditingController controller = TextEditingController();
  int number = 0;
  final QRservices _qrServices = QRservices();

  void incrementNumber() {
    setState(() {
      number++;
      controller.text = number.toString();
    });
  }

  void decrementNumber() {
    setState(() {
      if (number > 0) {
        number--;
        controller.text = number.toString();
      }
    });
  }

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
            SizedBox(
              width: 350,
              child: TextFormField(
                cursorWidth: 5,
                cursorColor: const Color(0xFF073042),
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Stations',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: incrementNumber,
                        icon: const Icon(Icons.add), // Removed const here
                      ),
                      IconButton(
                        onPressed: decrementNumber,
                        icon: const Icon(Icons.remove), // Removed const here
                      ),
                    ],
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    number = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                foregroundColor: Colors.white,
              ),
              onPressed: number > 0 && number <= 80
                  ? () async {
                      String docId = await _qrServices.addQRWithStationsNu(
                          context, number);
                      if (docId.isNotEmpty) {
                        await _qrServices.addQRCodeToUser(context, docId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRcode(qrData: docId, ticketType: 'metro'),
                          ),
                        );
                      }
                    }
                  : null,
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
