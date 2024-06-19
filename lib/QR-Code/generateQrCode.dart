import 'package:flutter/material.dart';
import 'package:tareeqy_metro/QR-Code/numberOfStaionsQR.dart';
import 'package:tareeqy_metro/QR-Code/priceQR.dart';
import 'package:tareeqy_metro/QR-Code/srcDstQR.dart';

class GenerateQrCode extends StatefulWidget {
  const GenerateQrCode({super.key});

  @override
  State<GenerateQrCode> createState() => _GenerateQrCodeState();
}

class _GenerateQrCodeState extends State<GenerateQrCode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF073042),
        title: const Text(
          "Get a Ticket",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 80),
                child: const Text(
                  "You can get your ticket in three ways : ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF073042),
                  ),
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              //=================================================================//
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    minimumSize: const Size(150, 50),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      // This gives the button squared edges
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NumberOfStationsQR()));
                  },
                  child: const Text(
                    'Enter number of stations',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              //=================================================================//
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    minimumSize: const Size(150, 50),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 12),
                    shape: RoundedRectangleBorder(
                      // This gives the button squared edges
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const srcDstQR()));
                  },
                  child: const Text(
                    'Enter the source and destination stations',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              //=================================================================//
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    minimumSize: const Size(150, 50),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      // This gives the button squared edges
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PriceQR()));
                  },
                  child: const Text(
                    'Enter the ticket Price',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              //=================================================================//
            ],
          ),
        ),
      ),
    );
  }
}
