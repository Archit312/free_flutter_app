import 'dart:ui';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
              child: Image.asset(
            'assets/backdrop.jpg',
            fit: BoxFit.cover,
          )),
          Positioned.fill(
              child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5,
              sigmaY: 5,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          )),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/logo.png',
                height: 225,
                width: 250,
                fit: BoxFit.fill,
              ),
            ],
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Welcome to Main Mumbai Bazar',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5.0, 0, 5, 8),
                  child: Text(
                    'Best Online Matka Play App',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
