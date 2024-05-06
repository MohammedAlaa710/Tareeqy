import 'package:flutter/material.dart';
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
                  // Navigate to another screen if sign up is successful
                  if (userCredential.user != null) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
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
}
