import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/admin/adminHomePage.dart';
import 'package:tareeqy_metro/components/custombuttonauth.dart';
import 'package:tareeqy_metro/components/customlogoauth.dart';
import 'package:tareeqy_metro/components/textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tareeqy_metro/homepage.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 50),
              const CustomLogoAuth(),
              Container(height: 20),
              const Text("SignUp",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              Container(height: 10),
              const Text("SignUp To Continue Using The App",
                  style: TextStyle(color: Colors.grey)),
              Container(height: 20),
              const Text(
                "username",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Container(height: 10),
              CustomTextField(
                  hinttext: "ُEnter Your username",
                  mycontroller: username,
                  obsecure: false),
              Container(height: 20),
              const Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Container(height: 10),
              CustomTextField(
                  hinttext: "ُEnter Your Email",
                  mycontroller: email,
                  obsecure: false),
              Container(height: 10),
              const Text(
                "Password",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Container(height: 10),
              CustomTextField(
                hinttext: "ُEnter Your Password",
                mycontroller: password,
                obsecure: true,
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                alignment: Alignment.topRight,
                child: const Text(
                  "Forgot Password ?",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          CustomButtonAuth(
              title: "SignUp",
              onPressed: () async {
                try {
                  final UserCredential userCredential =
                      await _auth.createUserWithEmailAndPassword(
                    email: email.text,
                    password: password.text,
                  );
                  if (userCredential.user != null) {
                    storeUserData(username.text, email.text);
                    checkIsAdmin().then((isAdmin) {
                      if (isAdmin != null && isAdmin) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => adminHomePage()));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      }
                    });
                  }
                } on FirebaseAuthException catch (e) {
                  // Handle error
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
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              }),
          Container(height: 20),

          Container(height: 20),
          // Text("Don't Have An Account ? Resister" , textAlign: TextAlign.center,)
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed("login");
            },
            child: const Center(
              child: Text.rich(TextSpan(children: [
                TextSpan(
                  text: "Have An Account ? ",
                ),
                TextSpan(
                    text: "Login",
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold)),
              ])),
            ),
          )
        ]),
      ),
    );
  }

  void storeUserData(String userName, String email) {
    String? userId = _auth.currentUser?.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({
          'userName': userName,
          'email': email,
          'isAdmin': false,
          'qrCodes': [],
          'wallet': 0.0,
        })
        .then((value) => print("User added"))
        .catchError((error) => print("Failed to add user: $error"));
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
}
