import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hmapp/donate.dart';
import 'package:hmapp/food.dart';
import 'package:hmapp/forget_pw.dart';
import 'package:hmapp/help.dart';
import 'package:hmapp/notifications.dart';
import 'package:hmapp/history.dart';
import 'package:hmapp/profile.dart';
import 'package:hmapp/search.dart';
import 'package:hmapp/splash.dart';
import 'account_data.dart';
import 'email_verify.dart';
import 'signup.dart';
import 'home.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Color(0xFF214847),
            ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginDemo(),
        '/search': (context) => Search(),
        '/profile': (context) => EditProfilePage(),
        '/donate': (context) => Donate(),
        '/signup': (context) => SignUpDemo(),
        '/notifications': (context) => Notifications(),
        '/history': (context) => History(),
        '/help': (context) => HelpPage(),
      },
    );
  }
}

class LoginDemo extends StatefulWidget {
  @override
  _LoginDemoState createState() => _LoginDemoState();
}

const highlightColor = Color(0xFF214847);
const backgroundColor = Color(0xFFe3dbc8);

class _LoginDemoState extends State<LoginDemo> {
  String error = "";
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  late StreamSubscription<User?> _listener;
  late Future<FirebaseApp> initializeFirebase;

  @override
  void initState() {
    initializeFirebase = initializeFirebaseFn();
    super.initState();
  }

  Future<FirebaseApp> initializeFirebaseFn() async {
    FirebaseApp firebase = await Firebase.initializeApp();
    setState(() {
      _listener = FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          log(user.toString());
          if (user.emailVerified == true) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .get()
                .then((doc) {
              var data = doc.data();
              if (data != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Welcome back.")));
                UserData userData = UserData();
                userData.setData(
                    data['fName'],
                    data["lName"],
                    data["dateOfBirth"].seconds.toString(),
                    data["phone"],
                    data["email"],
                    data["address"]);

                try {
                  FirebaseStorage.instance
                      .ref(user.uid)
                      .getDownloadURL()
                      .then((value) {
                    userData.setProfilePicture(value);
                  });
                } catch (e) {
                  userData.setProfilePicture(null);
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              }
            });
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return EmailVerificationPage();
            }));
          }
        }
      });
    });
    return firebase;
  }

  bool validateEmail(String email) {
    // Regular expression pattern for validating email addresses
    final RegExp emailRegex = RegExp(
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');

    return emailRegex.hasMatch(email);
  }

  void _signInWithEmailAndPassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password)
            .then((value) {
          if (value.user != null) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(value.user!.uid)
                .get()
                .then((doc) {
              var data = doc.data();
              if (data != null) {
                UserData userData = UserData();
                userData.setData(
                    data['fName'],
                    data["lName"],
                    data["dateOfBirth"].seconds.toString(),
                    data["phone"],
                    data["email"],
                    data["address"]);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              }
            });
          }
        });
      } on Exception catch (e) {
        setState(() {
          error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36),
        child: ListView(
          children: <Widget>[
            Image.asset('assets/images/logo.png'),
            if (error.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Colors.red,
                        child: Padding(
                          child: Text(
                            error,
                            style: TextStyle(color: Colors.white),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
            SizedBox(
              height: 16,
            ),
            const Text(
              "Sign In",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    scrollPadding: EdgeInsets.only(bottom: 40),
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!validateEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    scrollPadding: EdgeInsets.only(bottom: 40),
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[?!@#\$&*~]).{8,}$')
                              .hasMatch(value)) {
                        return 'Please enter a valid password.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter your password',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _signInWithEmailAndPassword,
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(highlightColor),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgetPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot password?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: highlightColor,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(
                      width: 8,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpDemo(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: highlightColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
