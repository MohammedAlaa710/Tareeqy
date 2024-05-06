import 'package:flutter/material.dart';
import 'package:tareeqy_metro/firebasebus/BusScreen.dart';
import 'package:tareeqy_metro/firebasemetro/metroscreen.dart';

//habtdi ta3del
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.fromLTRB(50, 100, 50, 50),
                child: Image.asset(
                  "assets/images/tareeqy.jpeg",
                  width: 300,
                  height: 170,
                )),
            Container(
              alignment: Alignment.center,
              child: const Text(
                ' Select Your Transportation',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 148, 189, 223),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5), // Shadow color
                          spreadRadius: 2, // Spread radius
                          blurRadius: 5, // Blur radius
                          offset: const Offset(0, 3), // Offset
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: IconButton(
                      /*style: ButtonStyle(
                        elevation: MaterialStateProperty.all(10),
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 158, 190, 235)),
                      ),*/

                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BusScreen()));  
                      },
                      icon: Image.asset(
                        "assets/images/BusIcon.png",
                        width: 200,
                        height: 130,
                      ),
                      color: Colors.black,
                      //iconSize: 1,
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 148, 189, 223),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5), // Shadow color
                          spreadRadius: 2, // Spread radius
                          blurRadius: 5, // Blur radius
                          offset: const Offset(0, 3), // Offset
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: IconButton(
                      /*style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Color.fromARGB(255, 158, 190, 235)),
                      ),*/
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MetroScreen()));
                      },
                      icon: Image.asset(
                        "assets/images/MetroIcon.png",
                        width: 200,
                        height: 130,
                      ),
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
