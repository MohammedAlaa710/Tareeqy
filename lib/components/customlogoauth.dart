import 'package:flutter/material.dart';

class CustomLogoAuth extends StatelessWidget {
  const CustomLogoAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(70)),
          child: Image.asset(
            "assets/images/tareeqy.jpeg",
            height: 180,
            width: 220,
            // fit: BoxFit.fill,
          )),
    );
  }
}