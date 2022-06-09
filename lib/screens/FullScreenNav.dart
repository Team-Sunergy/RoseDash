import 'package:bt01_serial_test/widgets/Speedometer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/Nav.dart';
import '../widgets/Speedometer.dart';
class FullScreenNav extends StatefulWidget {
  @override State<StatefulWidget> createState() => _FullScreenNavState();
}

class _FullScreenNavState extends State<FullScreenNav> {
  late Nav _nav;
  @override
  void initState() {
    super.initState();
    _nav = new Nav();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _nav,
        Positioned(
          bottom: 0,
          right: 0,
          child: ElevatedButton(onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            },
              child: Icon(Icons.close_fullscreen_outlined, color: Color(
                  0xffedd711), size: 40,),
              style: ElevatedButton.styleFrom(primary: Color(
                  0xff03050a),
                shape: CircleBorder(),
                padding: EdgeInsets.all(11),),),
        ),
        Positioned(bottom: 0, left: 15, child: Speedometer())
      ],
    );
  }
}