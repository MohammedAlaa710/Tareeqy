import 'package:flutter/material.dart';

class CustomButtonAuth extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  const CustomButtonAuth({super.key, this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
  return MaterialButton(
height: 50,
      minWidth: 200, // Adjusted width to 200
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Adjusted radius
    color: Colors.orange,
    textColor: Colors.white,
    onPressed: onPressed,
    child: Text(
      title,
      style: TextStyle(fontSize: 20), // Optional: Adjust text size if needed
    ),
  );
}

}
