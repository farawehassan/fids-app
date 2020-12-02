import 'dart:async';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';

/// A StatefulWidget class to show the splash screen of my application
class Splash extends StatefulWidget {

  static const String id = 'splash_screen_page';

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  /// Calling [navigate()] before the page loads
  @override
  void initState() {
    super.initState();
    navigate();
  }

  /// A function to set a 3 seconds timer for my splash screen to show
  /// and navigate to my [welcome] screen after
  void navigate(){
    Timer(
      Duration(seconds: 3),
      () {
        Navigator.of(context).pushReplacementNamed(WelcomeScreen.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFA6277C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Image.asset(
                'Assets/images/logo.png',
                height: 120,
                width: 120,
                fit: BoxFit.contain,
              ),
            ),
            Container(
              child: Center(
                child: Text(
                    '𝗖𝗼𝗻𝘁𝗲𝗺𝗽𝗼𝗿𝗮𝗿𝘆 𝘄𝗼𝗺𝗲𝗻 𝘄𝗲𝗮𝗿𝘀',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                    )
                ),
              ),
            ),
            Container(
              child: Center(
                child: Text(
                  'Made in Nigeria',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}