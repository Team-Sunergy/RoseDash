import 'package:flutter/material.dart';

class SerialIcon extends StatefulWidget {

  late final Stream<bool> connectStream;

  SerialIcon({required this.connectStream});

  @override
  State<StatefulWidget> createState() => _SRState();
}

class _SRState extends State<SerialIcon> {

  bool _connected = false;

  void _setConnect(bool event) {
    if (this.mounted) {
      setState(() {
        _connected = event;
      });
    }
  }

  Align _SerialIcon() {
    if (_connected) {
      return Align(alignment: Alignment.topLeft,
          child: (Container(child: Icon(
              IconData(0xf5c1, fontFamily: 'MaterialIcons'), size: 60,
              color: Color(0xff39ff14))))
      );
    }
    else {
      return Align(alignment: Alignment.topLeft,
          child: Row(children: [Container(child: Icon(
              IconData(0xe7e3, fontFamily: 'MaterialIcons'), size: 60,
              color: Color(0xfff72119))), Text(), ]));
    }
  }
  @override
  void initState() {
    super.initState();
    widget.connectStream.listen((event) {
      _setConnect(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _btIcon();
  }
}