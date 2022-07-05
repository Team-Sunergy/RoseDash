import 'package:flutter/material.dart';

class BluetoothIcon extends StatefulWidget {

  final Stream<bool> connectStream;

  BluetoothIcon({required this.connectStream});

  @override
  State<StatefulWidget> createState() => _BTState();
}


class _BTState extends State<BluetoothIcon> {

  bool _connected = false;

  void _setConnect(bool event) {
    if (this.mounted) {
      setState(() {
        _connected = event;
      });
    }
  }

  Align _btIcon() {
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
              color: Color(0xfff72119))), Text("Warning: Data may not be up to date. Please power cycle the arduino."), ]));
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