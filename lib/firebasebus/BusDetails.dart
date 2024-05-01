import 'package:flutter/material.dart';

class BusDetails extends StatelessWidget {
  String busNumber = "";
  List<String> regions = [];
  BusDetails({
    Key? key,
    required this.busNumber,
    required this.regions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        backgroundColor: Colors.white,
        title: Text(busNumber,
            style: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0), fontSize: 27)),
      ),

      //////////////////////
      backgroundColor: const Color.fromARGB(255, 128, 189, 250),
      body: ListView.builder(
        itemCount: regions.length, // Number of items in the list
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  10), // Adjust the radius to change the shape
              color: const Color.fromARGB(
                  255, 255, 255, 255), // Background color of the items
            ),
            margin: const EdgeInsets.symmetric(
                vertical: 5, horizontal: 10), // Adjust margin as needed
            child: ListTile(
              title: Text(
                regions[index],
                //'Item $index',
                style: const TextStyle(
                  fontSize: 20, // Adjust font size as needed
                  fontWeight: FontWeight.normal, // Adjust font weight as needed
                  color: Color.fromARGB(255, 0, 0, 0), // Text color
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void testprints(List<String> x) {
    for (int i = 0; i < x.length; i++) {
      print(x[i]);
    }
  }
}
