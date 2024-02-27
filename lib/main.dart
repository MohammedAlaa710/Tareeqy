import 'dart:io';

import 'package:flutter/material.dart';
//
import 'package:firebase_core/firebase_core.dart';
/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tareeqy_metro/test.dart'; */
import 'package:tareeqy_metro/homepage.dart';

//
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'AIzaSyBJx7pymI5ZBqsKYwQYR3fWkI-K_1UyHC8',
              appId: '1:337927737980:android:e9042cdca260b6daf42ff9',
              messagingSenderId: '337927737980',
              projectId: 'fluttertest-1a904'),
        )
      : await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}
