//@dart=2.9
import 'package:flutter/material.dart';

class RightTurnSignal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignalState();
}

class _SignalState extends State<RightTurnSignal> {
  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.topRight, child: (Container(child: Icon(IconData(0xf03cf, fontFamily: 'MaterialIcons'), size: 75, color: Color(0xffedd711)))));
  }
}