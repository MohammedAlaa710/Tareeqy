import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tareeqy_metro/admin/adminHomePage.dart';

class busQRCodeScannerPage extends StatefulWidget {
  const busQRCodeScannerPage({
    Key? key,
  }) : super(key: key);

  @override
  _busQRCodeScannerPageState createState() => _busQRCodeScannerPageState();
}

class _busQRCodeScannerPageState extends State<busQRCodeScannerPage> {
  String? qrText;
  bool isScanned = false;
  bool stop = false; // Control flag to stop the scanner

  Future<void> checkAndUpdateQRCode(String qrCodeString) async {
    if (isScanned) return; // If already scanned, do nothing

    // Search for the QR code document
    final qrCodeRef =
        FirebaseFirestore.instance.collection('BusQRcodes').doc(qrCodeString);
    final qrCodeDoc = await qrCodeRef.get();

    // If the document exists
    if (qrCodeDoc.exists) {
      final qrCodeData = qrCodeDoc.data() as Map<String, dynamic>;
      final bool inStatus = qrCodeData['in'] ?? false;
      final bool outStatus = qrCodeData['out'] ?? false;

      // If 'in' is false, update it to true
      if (!inStatus) {
        await qrCodeRef.update({'in': true});

        isScanned = true; // Mark as scanned
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('the first scan (in=true)')),
        );
      } else {
        // If 'in' is true, update 'out' to true
        if (!outStatus) {
          isScanned = true; // Mark as scanned
          String price = qrCodeData['price'];
          print("Ticket price: $price");
          await qrCodeRef.update({'out': true});
          print('Second scan: out=true');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('the second scan (out=true)')),
          );
        } else {
          // If 'out' is true, the QR code is already used
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('already scaned twice (in=out=true)')),
          );
          throw Exception('This QR code is already used');
        }
      }
    } else {
      throw Exception('QR code not found');
    }
  }

  @override
  void dispose() {
    // Dispose of any resources here if necessary
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF073042),
        title: const Text(
          'Bus Ticket Scanner',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: stop
                ? const Center(child: Text('Processing QR code...'))
                : MobileScanner(
                    onDetect: (qrcodeCapture) async {
                      if (qrcodeCapture.barcodes.isEmpty || stop) return;

                      final qrcode = qrcodeCapture.barcodes.first;
                      if (qrcode.rawValue != null) {
                        setState(() {
                          qrText = qrcode.rawValue!;
                          stop = true; // Stop further scanning
                          print("ticketId $qrText");
                        });

                        try {
                          await checkAndUpdateQRCode(qrText!);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('QR code processed successfully'),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          // Navigate back to the previous page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AdminHomePage()),
                          );
                        } catch (e) {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          // Allow scanning again if an error occurs
                          setState(() {
                            stop = false;
                          });
                        }
                      }
                    },
                  ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (qrText != null)
                  ? Text('Scan result: $qrText')
                  : const Text('Scan the code'),
            ),
          ),
        ],
      ),
    );
  }
}
