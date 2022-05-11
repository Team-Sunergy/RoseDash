import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'constants.dart';
import 'screens/homePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SVT: Alpha Dashboard",
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}
