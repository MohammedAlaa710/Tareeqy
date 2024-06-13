import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tareeqy_metro/admin/adminHomePage.dart';
import 'package:tareeqy_metro/drivers/driverScreen.dart';
import 'package:tareeqy_metro/homepage.dart';
import 'package:tareeqy_metro/Auth/Register.dart';
import 'package:tareeqy_metro/firebasemetro/metroService.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkCurrentUser();
  }

  void checkCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        bool? isAdmin = await checkIsAdmin();
        if (isAdmin != null) {
          if (isAdmin) {
            // If the user is an admin, navigate to adminHomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const adminHomePage()),
            );
          } else {
            // If the user is not an admin, navigate to HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          print('isAdmin field not found or null');
          // Handle case where isAdmin field is not found or null
        }
      } catch (e) {
        print('Error checking user admin status: $e');
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                ),
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(70)),
                    child: Image.asset("assets/images/tareeqy.jpeg",
                        width: 90, height: 90),
                  ),
                ),
                Container(height: 20),
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                Container(height: 2),
                const Text(
                  "Login to continue using the app",
                  style: TextStyle(color: Colors.grey),
                ),
                Container(height: 20),
                const Text(
                  "Email",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(height: 5),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Enter Your Email",
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(color: Colors.grey)),
                  ),
                ),
                Container(height: 15),
                const Text(
                  "Password",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(height: 5),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Enter Your Password",
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(color: Colors.grey)),
                  ),
                ),
              ],
            ),
            Container(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45),
              child: MaterialButton(
                height: 50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                textColor: Colors.white,
                color: Colors.blue,
                onPressed: () async {
                  try {
                    final UserCredential userCredential =
                        await _auth.signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                    // Navigate to another screen if sign in is successful
                    if (userCredential.user != null) {
                      if (await checkIsDriver()) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DriverScreen()));
                      } else {
                        checkIsAdmin().then((isAdmin) {
                          if (isAdmin != null && isAdmin) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const adminHomePage()));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()));
                          }
                        });
                      }
                    }
                  } on FirebaseAuthException catch (e) {
                    // Handle error
                    print(e.message);
                    BuildContext dialogContext;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        dialogContext = context;
                        return AlertDialog(
                          title: const Text('Error'),
                          content: Text(e.message ?? 'An error occurred'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                metroService metroservice = metroService();
                                metroservice.getStations();
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Container(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account ?  ",
                  style: TextStyle(fontSize: 15),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Register()));
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<bool?> checkIsAdmin() async {
    String? userId = _auth.currentUser?.uid;
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        return snapshot.get('isAdmin');
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error getting user field: $e');
      return null;
    }
  }

  Future<bool> checkIsDriver() async {
    String? userId = _auth.currentUser?.uid;
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(userId)
          .get();
      return snapshot.exists;
    } catch (e) {
      print('Error checking if user is a driver: $e');
      return false;
    }
  }
}
