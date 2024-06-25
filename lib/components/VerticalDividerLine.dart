import 'package:flutter/material.dart';

class VerticalDividerLine extends StatelessWidget {
  const VerticalDividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 20,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color(0xFF00796B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
