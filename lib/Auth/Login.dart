import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tareeqy_metro/Auth/AuthService.dart';
import 'package:tareeqy_metro/admin/adminHomePage.dart';
import 'package:tareeqy_metro/drivers/driverScreen.dart';
import 'package:tareeqy_metro/homepage.dart';
import 'package:tareeqy_metro/Auth/Register.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  AuthService authService = AuthService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: const Color(0xFF073042), // Desired status bar color
    ));

    authService.checkCurrentUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      opacity: 0.5,
      progressIndicator: CircularProgressIndicator(),
      child: Scaffold(
        backgroundColor: Color(0xFF073042),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  SizedBox(height: 40),
                  Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                      "Enter Your Email", Icons.email, emailController),
                  SizedBox(height: 20),
                  _buildInputField(
                      "Enter Your Password", Icons.lock, passwordController,
                      isPassword: true),
                  SizedBox(height: 30),
                  _buildLoginButton(),
                  SizedBox(height: 20),
                  _buildRegisterLink(),
                ],
              ),
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
      style: TextStyle(color: Colors.white),
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

  Widget _buildLoginButton() {
    return MaterialButton(
      height: 50,
      minWidth: 200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      textColor: Colors.white,
      color: Color(0xFF00796B),
      onPressed: isLoading ? null : () => _login(),
      child: Text(
        "Login",
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Register()),
            );
          },
          child: Text(
            " Register",
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _login() async {
    setState(() {
      isLoading = true;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login Error', style: TextStyle(color: Colors.red)),
            content: Text('Please enter both email and password.',
                style: TextStyle(color: Colors.black87)),
            actions: <Widget>[
              TextButton(
                child: Text('OK', style: TextStyle(color: Colors.blue)),
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
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        if (await authService.checkIsDriver()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DriverScreen()),
          );
        } else {
          authService.checkIsAdmin().then((isAdmin) {
            if (isAdmin != null && isAdmin) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminHomePage()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            }
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      } else {
        errorMessage = e.message ?? 'Login failed. Please try again later.';
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login Error', style: TextStyle(color: Colors.red)),
            content:
                Text(errorMessage, style: TextStyle(color: Colors.black87)),
            actions: <Widget>[
              TextButton(
                child: Text('OK', style: TextStyle(color: Colors.blue)),
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
    } catch (e) {
      print('Unexpected error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error', style: TextStyle(color: Colors.red)),
            content: Text(
                'An unexpected error occurred. Please try again later.',
                style: TextStyle(color: Colors.black87)),
            actions: <Widget>[
              TextButton(
                child: Text('OK', style: TextStyle(color: Colors.blue)),
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
