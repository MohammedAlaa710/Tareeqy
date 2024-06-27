import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tareeqy_metro/Auth/AuthService.dart';
import 'package:tareeqy_metro/Auth/Login.dart';
import 'package:tareeqy_metro/Admin/AdminHomePage.dart';
import 'package:tareeqy_metro/components/CustomButtonAuth.dart';
import 'package:tareeqy_metro/components/MyDropdownSearch.dart';
import 'package:tareeqy_metro/Bus/busService.dart';
import 'package:tareeqy_metro/HomePage.dart';

// ignore: must_be_immutable
class Register extends StatefulWidget {
  String? collection;
  Register({super.key, String this.collection = "users"});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
//  TextEditingController busId = TextEditingController();
  String busId = '';
  late final BusService _busService = BusService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthService authService = AuthService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.collection == 'Drivers') {
      isLoading = true;
      _loadBusData();
      isLoading = false;
    }
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF073042),
    ));
  }

  Future<void> _loadBusData() async {
    await _busService.getBuses();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      opacity: 0.5,
      progressIndicator: const CircularProgressIndicator(),
      child: Scaffold(
        backgroundColor: const Color(0xFF073042),
        appBar: AppBar(
          backgroundColor: const Color(0xFF073042),
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          "assets/images/tareeqy.jpeg",
                          width: 220,
                          height: 180,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "SignUp",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "SignUp To Continue Using The App",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField("Enter Your Username", Icons.person, username),
                const SizedBox(height: 20),
                _buildInputField("Enter Your Email", Icons.email, email),
                const SizedBox(height: 20),
                _buildInputField("Enter Your Password", Icons.lock, password,
                    isPassword: true),
                const SizedBox(height: 20),
                if (widget.collection == 'Drivers') ...[
                  const Text(
                    "Choose the Bus Id for The Driver",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyDropdownSearch(
                      fromto: 'Bus Id',
                      items: _busService.buses.toSet(),
                      selectedValue: busId,
                      onChanged: (value) {
                        setState(() {
                          busId = value!;
                        });
                      }),
                  const SizedBox(height: 20),
                ],
                const SizedBox(height: 30),
                _buildSignUpButton(),
                const SizedBox(height: 20),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      String hintText, IconData icon, TextEditingController controller,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.grey[200]?.withOpacity(0.5) ?? Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Center(
      child: CustomButtonAuth(
        title: "Sign Up",
        onPressed: isLoading ? null : () => _signUp(),
      ),
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      },
      child: const Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text: "Have An Account? ",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              TextSpan(
                text: "Login",
                style: TextStyle(
                    color: Color(0xFF00796B),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    setState(() {
      isLoading = true;
    });

    String usernameText = username.text.trim();
    String emailText = email.text.trim();
    String passwordText = password.text.trim();

    if (usernameText.isEmpty ||
        emailText.isEmpty ||
        passwordText.isEmpty ||
        (widget.collection == 'Drivers' && busId.isEmpty)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                const Text('SignUp Error', style: TextStyle(color: Colors.red)),
            content: const Text('Please fill all fields.',
                style: TextStyle(color: Colors.black87)),
            actions: <Widget>[
              TextButton(
                child: const Text('OK', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          );
        },
      );

      setState(() {
        isLoading = false;
      });

      return;
    }

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailText,
        password: passwordText,
      );

      if (userCredential.user != null) {
        await authService.storeUserData(
          usernameText,
          emailText,
          context,
          collection: widget.collection,
          busId: busId,
        );

        authService.checkIsAdmin().then((isAdmin) {
          if (isAdmin != null && isAdmin || widget.collection == "Drivers") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AdminHomePage()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'The email address is already in use.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      } else {
        errorMessage = e.message ?? 'SignUp failed. Please try again later.';
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                const Text('SignUp Error', style: TextStyle(color: Colors.red)),
            content: Text(errorMessage,
                style: const TextStyle(color: Colors.black87)),
            actions: <Widget>[
              TextButton(
                child: const Text('OK', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          );
        },
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
