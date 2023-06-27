// @dart=2.9
import 'package:flutter/material.dart';
import 'screens/homePage.dart';
// Database
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Lock in landscape
import 'package:flutter/services.dart';

void main() {
  MyApp app = MyApp();

  runApp(app);
}

class MyApp extends StatelessWidget {

  void initState() {
  }

  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);  // to re-show bars
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

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


            debugShowCheckedModeBanner: false,
          );
        }
        // Otherwise, show something whilst waiting for initialization to complete
        return CircularProgressIndicator();
      },
    );


  }
}

