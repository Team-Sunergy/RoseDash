import 'dart:async';

import 'package:flutter/material.dart';

// Import the firebase_core and cloud_firestore plugin
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:segment_display/segment_display.dart';
import 'package:sprintf/sprintf.dart';

class UnderHood {
  late int cellId;
  late double instV;
  late bool isShunting;
  late double intRes;
  late double openV;
}

class AddBMSData extends StatefulWidget {
  final Stream<double> socStream;
  final Stream<double> lowStream;
  final Stream<double> hiStream;
  final Stream<double> packVoltStream;
  final Stream<double> currentDrawStream;
  final Stream<double> deltaStream;
  final Stream<int> hiTempStream;
  final Stream<Object> underHoodStream;
  final Stream<int> speedStream;
  final Stream<Set<String>> ctcStream;
  final Stream<Set<String>> ptcStream;
  final Stream<String> apwiStream;
  final Stream<double> latStream;
  final Stream<double> longStream;
  final Stream<double> altStream;
  AddBMSData({required this.socStream, required this.lowStream,
              required this.hiStream, required this.packVoltStream,
              required this.currentDrawStream, required this.hiTempStream,
              required this.deltaStream, required this.speedStream,
              required this.underHoodStream, required this.ctcStream,
              required this.ptcStream, required this.apwiStream,
              required this.latStream, required this.longStream,
              required this.altStream});

 @override createState() => _AddBMSDataState();
}

class _AddBMSDataState extends State<AddBMSData> {
  // Create a CollectionReference called users that references the firestore collection
  CollectionReference bmsData = FirebaseFirestore.instance.collection('VisibleTelemetry');
  CollectionReference batteryData = FirebaseFirestore.instance.collection('UnderTheHood');
  double soc = 82.8;
  double low = 32.2;
  double high = 34.2;
  double recHi = 0.0;
  double packVoltSum = 0.0;
  double currentDraw = 10.0;
  int highTemp = 31;
  double delta = 0.0;
  double _speed = 0.0;
  int _cellID = 0;
  double _instantVoltage = 0;
  bool _isShunting = false;
  double _internalResistance = 0;
  double _openVoltage = 0;
  Set<String>? _ctcSet;
  Set<String>? _ptcSet;
  String? _apv;
  double lat = 0;
  double long = 0;
  int alt = 0;

  void _setCTC(val) {
    if (this.mounted)
    setState(() {
      _ctcSet = val;
    });
  }

  void _setPTC(val) {
    if (this.mounted)
      setState(() {
        _ptcSet = val;
      });
  }

  void _setAPV(String val) {
    if (this.mounted)

      setState(() {
          _apv = val;
      });
  }
  void _setSOC(val) {
    if (this.mounted)
    setState(() {soc = val;});

  }

  void _setLow(val) {
    if (this.mounted)
    setState(() {low = val;});
  }

  void _setHigh(val) {
    if (this.mounted)
    setState(() {high = val;});
  }

  void _setPackVoltSum(val) {
    if (this.mounted)
    setState(() {packVoltSum = val;});
  }

  void _setHighTemp(val) {
    if (this.mounted)
    setState(() {highTemp = val;});
  }

  void _setCurrentDraw(val) {
    if (this.mounted)
    setState(() {currentDraw = val;});
  }

  void _setDelta() {
    if (this.mounted)
    setState((){delta = high - low;});
  }

  void _setLat(val) {
    if (this.mounted)
      setState(() {
        lat = val;
      });
  }

  void _setLong(val) {
    if (this.mounted)
      setState(() {
        long = val;
      });
  }

  void _setAlt(double val) {
    if (this.mounted)
      setState(() {
        alt = (val * 3.28084).toInt();
      });
  }

  void _setSpeed(val) {
    if (this.mounted)
      setState(() {_speed = val;});
  }

  void _setParams(val) {
    if (this.mounted)
      setState(() {
        _cellID = val.cellId;
        _instantVoltage = val.instV;
        _isShunting = val.isShunting;
        _internalResistance = val.intRes;
        _openVoltage = val.openV;
      });
  }

  Future<void> addBMSData() {
    // Call the user's CollectionReference to add a new user
    return bmsData
        .add({
      'soc': soc, // John Doe
      'lowVolt': low, // Stokes and Sons
      'highVolt': high,
      'packVolt': packVoltSum,
      'currentDraw': currentDraw,
      'delta': delta,
      'hiTemp': highTemp,
      'speed' : _speed,
      'ctcSet' : _ctcSet != null ? _ctcSet.toString() : 0,
      'ptcSet' : _ptcSet != null ? _ptcSet.toString() : 0,
      'apvSet' : _apv != null ? _apv : 0,
      'lat' : lat,
      'long' : long,
      'alt' : alt,
      'time': DateTime.now(),
      // 42
    })
        .then((value) => print("BMS Data Added"))
        .catchError((error) => print("Failed to add BMS data: $error"));
  }

  Future<void> addBatteryData() {
    // Call the user's CollectionReference to add a new user
    return batteryData
        .add({
      'Cell_ID': _cellID, // John Doe
      'Instant_Voltage': _instantVoltage, // Stokes and Sons
      'Shunting': _isShunting,
      'Internal_Resistance': _internalResistance,
      'Open_Voltage': _openVoltage,
      'time': DateTime.now(),
      // 42
    })
        .then((value) => print("Battery Data Added"))
        .catchError((error) => print("Failed to add Battery data: $error"));
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (Timer t1) => addBMSData());
    Timer.periodic(Duration(seconds: 5), (Timer t2) => addBatteryData());

    widget.socStream.listen((soc) {_setSOC(soc);});
    widget.lowStream.listen((low) {_setLow(low);});
    widget.hiStream.listen((hi) {_setHigh(hi);});
    widget.packVoltStream.listen((pvs) {_setPackVoltSum(pvs);});
    widget.currentDrawStream.listen((cd) {_setCurrentDraw(cd);});
    widget.deltaStream.listen((event) {_setDelta();});
    widget.hiTempStream.listen((hiTemp) {_setHighTemp(hiTemp);});
    widget.deltaStream.listen((delta) {_setDelta();});
    widget.underHoodStream.listen((event) {_setParams(event);});
    widget.speedStream.listen((event) {_setSpeed(event);});
    widget.apwiStream.listen((event) {_setAPV(event);});
    widget.ptcStream.listen((event) {_setPTC(event);});
    widget.ctcStream.listen((event) {_setCTC(event);});
    widget.latStream.listen((event) {_setLat(event);});
    widget.longStream.listen((event) {_setLong(event);});
    widget.altStream.listen((event) {_setAlt(event);});
  }

  @override
  Widget build(BuildContext context) {
    Future<void> addBatteryData() {
      // Call the user's CollectionReference to add a new user
      return batteryData
          .add({
        'Cell_ID': _cellID, // John Doe
        'Instant_Voltage': _instantVoltage, // Stokes and Sons
        'Shunting': _isShunting,
        'Internal_Resistance': _internalResistance,
        'Open_Voltage': _openVoltage,
        'time': DateTime.now(),
        // 42
      })
          .then((value) => print("Battery Data Added"))
          .catchError((error) => print("Failed to add Battery data: $error"));
    }

    return Column(
      children: [
        TextButton(
          onPressed: () {
            addBMSData();
            },
          child: Text(
            "Add BMS Data",
          ),
        ),
        TextButton(
          onPressed: () {
            addBatteryData();
          },
          child: Text(
            "Add Battery Data",
          ),
        ),
        Container(
            child: SixteenSegmentDisplay(
              value: sprintf("%0.3f", [recHi]),
              size: 4.0,
              backgroundColor: Colors.transparent,
              segmentStyle: RectSegmentStyle(
                  enabledColor: Color(0xffedd711),
                  disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
            )),
        Container(
            child: SixteenSegmentDisplay(
              value: sprintf("%d", [_cellID]),
              size: 4.0,
              backgroundColor: Colors.transparent,
              segmentStyle: RectSegmentStyle(
                  enabledColor: Color(0xffedd711),
                  disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
            )),
      ],
    );
  }
}