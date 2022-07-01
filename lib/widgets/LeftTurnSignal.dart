//@dart=2.9
import 'package:flutter/material.dart';

class LeftTurnSignal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignalState();
}

class _SignalState extends State<LeftTurnSignal> {
  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.topLeft, child: (Container(child: Icon(IconData(0xf04c1, fontFamily: 'MaterialIcons'), size: 75, color: Color(0xffedd711)))));
  }
}