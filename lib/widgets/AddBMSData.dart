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
  
  AddBMSData({required this.socStream, required this.lowStream,
              required this.hiStream, required this.packVoltStream,
              required this.currentDrawStream, required this.hiTempStream,
              required this.deltaStream, required this.underHoodStream});

 @override createState() => _AddBMSDataState();
}

class _AddBMSDataState extends State<AddBMSData> {
  Stream _bms = FirebaseFirestore.instance.collection('BMS')
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots(includeMetadataChanges: true);
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
  double speed = 0.0;
  int _cellID = 0;
  double _instantVoltage = 0;
  bool _isShunting = false;
  double _internalResistance = 0;
  double _openVoltage = 0;

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

  void updateHighVolt(QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        if (this.mounted)
        setState(() {
        recHi = doc['highVolt'];
      });
    });
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


  @override
  void initState() {
    super.initState();
    widget.socStream.listen((soc) {_setSOC(soc);});
    widget.lowStream.listen((low) {_setLow(low);});
    widget.hiStream.listen((hi) {_setHigh(hi);});
    widget.packVoltStream.listen((pvs) {_setPackVoltSum(pvs);});
    widget.currentDrawStream.listen((cd) {_setCurrentDraw(cd);});
    widget.deltaStream.listen((event) {_setDelta();});
    widget.hiTempStream.listen((hiTemp) {_setHighTemp(hiTemp);});
    widget.deltaStream.listen((delta) {_setDelta();});
    widget.underHoodStream.listen((event) {_setParams(event);});
    _bms.listen(
    (snapshot) => {
      print("update occurred"),
      updateHighVolt(snapshot)
    },
    onError: (error) => print("Listen failed: $error"),
    );
  }

  @override
  Widget build(BuildContext context) {
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