// @dart=2.9
import 'package:flutter/material.dart';
import 'screens/homePage.dart';
// Database
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  MyApp app = MyApp();
  runApp(app);
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return CircularProgressIndicator();
        }
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: "SVT: Alpha Dashboard",
            theme: ThemeData.dark(),
            darkTheme: ThemeData.dark(),
            home: HomePage(),
          );
        }
        // Otherwise, show something whilst waiting for initialization to complete
        return CircularProgressIndicator();
      },
    );



  }
}
