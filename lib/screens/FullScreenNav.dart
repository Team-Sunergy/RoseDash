import 'package:flutter/material.dart';
import '../widgets/Nav.dart';
import '../widgets/Speedometer.dart';
class FullScreenNav extends StatefulWidget {
  final Nav nav;
  FullScreenNav({required this.nav});
  @override State<StatefulWidget> createState() => _FullScreenNavState();
}

class _FullScreenNavState extends State<FullScreenNav> {
  late Nav _nav;
  @override
  void initState() {
    super.initState();
    _nav = widget.nav;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _nav,
        Positioned(
          bottom: 0,
          right: 0,
          child: Column(
            children: [
              ElevatedButton(onPressed: () {
                setState(() {
                  Nav.recenter = !Nav.recenter;
                });
              },
                child: Icon(Icons.navigation, color: Nav.recenter ? Color(
                    0xffedd711): Colors.white, size: 40,),
                style: ElevatedButton.styleFrom(primary: Color(
                    0xff03050a),
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(11),),),
              Container(height: 5),
              ElevatedButton(onPressed: () {
                  setState(() {
                    Nav.recenter = true;
                    Navigator.pop(context);
                  });
                },
                  child: Icon(Icons.close_fullscreen_outlined, color: Color(
                      0xffedd711), size: 40,),
                  style: ElevatedButton.styleFrom(primary: Color(
                      0xff03050a),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(11),),),
            ],
          ),
        ),
      ],
    );
  }
}