import 'package:flutter/material.dart';
import 'package:tareeqy_metro/firebasemetro/metro_Screen.dart';
import 'package:tareeqy_metro/firebasemetro/metroscreen.dart';
import 'package:tareeqy_metro/test.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const MetroScreen();
              },
            ),
          );
        },
        backgroundColor: const Color(0xff1C88D9),
        shape:
            const BeveledRectangleBorder(side: BorderSide(color: Colors.black)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      backgroundColor: const Color(0xff1F1F1F),
      appBar: AppBar(
        title: const Text(
          'Firebase',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff1F88D9),
      ),
    );
  }
}
