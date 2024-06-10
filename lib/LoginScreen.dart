import 'package:bitirmeson/tabs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitirmeson/tema.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Auth.dart';
import 'KayitOl.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool goz = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Tema tema = Tema();
  AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Login Failed'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.indigo.shade100,
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(5, 35, 20, 20),
                    child: RichText(
                      text: TextSpan(
                        text: 'RATELY',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 50.0,
                          color: Color(0xFF6959cd),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF6959cd),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: _emailController,
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: tema.inputDec("E-mail", Icons.mail),
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                style: TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                obscureText: !goz,
                                decoration: tema.inputDec("Password", Icons.vpn_key_rounded),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  goz = !goz;
                                });
                              },
                              icon: Icon(
                                Icons.remove_red_eye,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(100, 0, 0, 0),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      rememberMe = !rememberMe;
                                    });
                                  },
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: rememberMe
                                        ? Icon(Icons.check, color: Colors.white, size: 16)
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'Remember me',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 13.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );

                              // Kullanıcı bilgilerini Shared Preferences'a kaydet
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('isLoggedIn', true);
                              await prefs.setString('email', _emailController.text);
                              await prefs.setString('password', _passwordController.text);

                              // Anasayfaya yönlendir
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => TabsScreen()),
                              );
                            } catch (e) {
                              _showErrorDialog("Invalid email or password. Please try again.");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            side: BorderSide(width: 2.0, color: Colors.indigo.shade50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              'Login',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.bebasNeue(
                                fontSize: 25.0,
                                color: Colors.indigo.shade500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => KayitOl()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            side: BorderSide(width: 2.0, color: Colors.indigo.shade50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              'Sign Up',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.bebasNeue(
                                fontSize: 25.0,
                                color: Colors.indigo.shade500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        SignInButton(
                          Buttons.Google,
                          onPressed: () {
                            AuthService().signInWithGoogle(context);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
