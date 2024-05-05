import 'package:flutter/material.dart';

class CustButton extends StatelessWidget {
  final String title;
  final void Function() onPressed;
  const CustButton({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      height: 40,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: const Color(0xff3194FF),
      textColor: Colors.white,
      child: Text(title),
    );
  }
}
