// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAs_iRzz72pk3WDNDYdpebKSBfyrKU6_FU',
    appId: '1:198190540592:web:c8890d3c1c9c91bb064af5',
    messagingSenderId: '198190540592',
    projectId: 'rosedash-fd71d',
    authDomain: 'rosedash-fd71d.firebaseapp.com',
    storageBucket: 'rosedash-fd71d.appspot.com',
    measurementId: 'G-7FECZWFK78',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD6oTSArv26RnPrWBy8E6jx6zQ11ZZtXRw',
    appId: '1:198190540592:android:92d49ef47efc9546064af5',
    messagingSenderId: '198190540592',
    projectId: 'rosedash-fd71d',
    storageBucket: 'rosedash-fd71d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDJFIQMYY3O-WpXUX0Bf8frkM0x9zzoHOE',
    appId: '1:198190540592:ios:678ef11c398fd9a2064af5',
    messagingSenderId: '198190540592',
    projectId: 'rosedash-fd71d',
    storageBucket: 'rosedash-fd71d.appspot.com',
    iosClientId: '198190540592-o2emg1640nplgsvpgp3g3hmcj7ug7kk3.apps.googleusercontent.com',
    iosBundleId: 'com.example.bt01SerialTest',
  );
}
