import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login.dart';
import 'auth/register.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

bool _disabled = false;

void init() async {
  try {
    await FirebaseAuth.instance.currentUser!.reload();
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-disabled') {
      // User is disabled.
      Fluttertoast.showToast(
          msg: "YOUR ID HAS BEEN DISABLED",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          // backgroundColor: Colors.red,
          // textColor: Colors.white,
          fontSize: 16.0);
      _disabled = true;
    } else if (e.code == 'user-not-found') {
      Fluttertoast.showToast(
          msg: "YOUR ID HAS BEEN DELETED",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          // backgroundColor: Colors.red,
          // textColor: Colors.white,
          fontSize: 16.0);
      _disabled = true;
    }
  }
  try {
    await FirebaseFirestore.instance
        .collection('UsersData')
        .doc(FirebaseAuth.instance.currentUser!.uid.toString())
        .get()
        .then((value) {
      if (!value.exists) {
        FirebaseAuth.instance.currentUser!.delete();
        Fluttertoast.showToast(
            msg: "Please complete Authentication",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            // backgroundColor: Colors.red,
            // textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  } on PlatformException {
    Fluttertoast.showToast(
        msg: "Something went wrong please restart the app",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        // backgroundColor: Colors.red,
        // textColor: Colors.white,
        fontSize: 16.0);
  }
}

class _MyAppState extends State<MyApp> {
  bool _isTimerDone = false;
  @override
  void initState() {
    init();
    Timer(
        const Duration(seconds: 2), () => setState(() => _isTimerDone = true));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Mumbai Bazar',
      theme: ThemeData.dark(),
      home: _disabled
          ? const Loginscreen()
          : StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting ||
                    !_isTimerDone) {
                  return const SplashScreen();
                }
                if (userSnapshot.hasData) {
                  return FirebaseAuth.instance.currentUser == null
                      ? const Loginscreen()
                      : const Homepage();
                }
                return const Loginscreen();
              }),
      routes: {
        Loginscreen.routeName: (ctx) => const Loginscreen(),
        Register.routeName: (ctx) => const Register(),
      },
      navigatorObservers: const [],
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (ctx) => const Loginscreen(),
        );
      },
    );
  }
}
