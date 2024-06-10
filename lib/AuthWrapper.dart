import 'package:bitirmeson/LoginScreen.dart';
import 'package:bitirmeson/tabs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? user;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    // Firebase ile oturum açmış kullanıcıyı kontrol et
    user = FirebaseAuth.instance.currentUser;

    // Eğer oturum açmış kullanıcı yoksa, Shared Preferences ile kontrol et
    if (user == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isLoggedIn = prefs.getBool('isLoggedIn');
      if (isLoggedIn != null && isLoggedIn) {
        // Eğer oturum bilgisi varsa, Firebase ile tekrar giriş yap
        String? email = prefs.getString('email');
        String? password = prefs.getString('password');
        if (email != null && password != null) {
          try {
            UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            setState(() {
              user = userCredential.user;
            });
          } catch (e) {
            print(e);
          }
        }
      }
    }

    // Kullanıcı durumu güncelle
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return LoginScreen();
    } else {
      return TabsScreen();
    }
  }
}
