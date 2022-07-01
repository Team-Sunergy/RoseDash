//@dart=2.9
import 'package:flutter/material.dart';

class LeftTurnSignal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignalState();
}

class _SignalState extends State<LeftTurnSignal> with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController =
    new AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: _animationController,
        child: Align(alignment: Alignment.topLeft,
            child: (Container(child: Icon(
                IconData(0xf04c1, fontFamily: 'MaterialIcons'), size: 75,
                color: Color(0xffedd711))))
        ));

    return Align(alignment: Alignment.topLeft, child: (Container(child: Icon(IconData(0xf04c1, fontFamily: 'MaterialIcons'), size: 75, color: Color(0xffedd711)))));
  }
}