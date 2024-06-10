import 'package:bitirmeson/AuthWrapper.dart';
import 'package:bitirmeson/KayitOl.dart';
import 'package:bitirmeson/LoginScreen.dart';
import 'package:bitirmeson/oylama.dart';
import 'package:bitirmeson/profile.dart';
import 'package:bitirmeson/tabs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
