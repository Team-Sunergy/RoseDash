//@dart=2.9
import 'package:flutter/material.dart';

class RightTurnSignal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignalState();
}

class _SignalState extends State<RightTurnSignal> with SingleTickerProviderStateMixin {
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
      child: Align(alignment: Alignment.topRight,
        child: (Container(child: Icon(
        IconData(0xf03cf, fontFamily: 'MaterialIcons'), size: 75,
        color: Color(0xffedd711))))
    ));

    /*if (on) {
      return Align(alignment: Alignment.topRight,
          child: (Container(child: Icon(
              IconData(0xf03cf, fontFamily: 'MaterialIcons'), size: 75,
              color: Color(0xffedd711)))));
    }
    else
    {
      return Container();
    }*/
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}