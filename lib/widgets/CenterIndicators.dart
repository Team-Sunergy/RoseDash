import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:segment_display/segment_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CenterIndicators extends StatefulWidget {
  @override
  createState() => _CenterIndicatorsState();
}

class _CenterIndicatorsState extends State<CenterIndicators> {

  Stream _dB = FirebaseFirestore.instance.collection('VisibleTelemetry')
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots(includeMetadataChanges: true);

  double soc = 82.8;
  double low = 32.2;
  double high = 34.2;
  double packVoltSum = 0.0;
  double currentDraw = 10.0;
  int highTemp = 31;

  void _setSOC(val) {
    if (this.mounted)
    setState(() {
      soc = val;
    });
  }

  void _setLow(val) {
    if (this.mounted)
    setState(() {
      low = val;
    });
  }

  void _setHigh(val) {
    if (this.mounted)
    setState(() {
      high = val;
    });
  }

  void _setPackVoltSum(val) {
    if (this.mounted)
    setState(() {
      packVoltSum = val;
    });
  }

  void _setHighTemp(val) {
    if (this.mounted)
    setState(() {
      highTemp = val;
    });
  }

  void _setCurrentDraw(val) {
    if (this.mounted)
    setState(() {
      currentDraw = val;
    });
  }

  void setMetrics(QuerySnapshot snapshot) {
    snapshot.docs.forEach((doc) {
      if (this.mounted)
        setState(() {
          _setSOC(doc['soc']);
          _setLow(doc['lowVolt']);
          _setHigh(doc['highVolt']);
          _setHighTemp(doc['hiTemp']);
          _setPackVoltSum(doc['packVolt']);
          _setCurrentDraw(doc['currentDraw']);
        });
    });
  }

  @override
  void initState() {
    super.initState();
    _dB.listen((event) {setMetrics(event);});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Container(
            //width: 150,
            //color: Colors.red,
            child: SixteenSegmentDisplay(
          value: soc.toString() + "%",
          size: 4.0,
          backgroundColor: Colors.transparent,
          segmentStyle: RectSegmentStyle(
              enabledColor: Color(0xffedd711),
              disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
        )),
        Container(height: 20, child: Text("State of Charge", style: TextStyle(color: Colors.white70.withOpacity(0.65)),)),
        Container(height: 12,),
        Container(
            child: SixteenSegmentDisplay(
          value: sprintf("%0.3f", [high]),
          size: 4.0,
          backgroundColor: Colors.transparent,
          segmentStyle: RectSegmentStyle(
              enabledColor: Color(0xffedd711),
              disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
        )),
        Container(height: 20, child: Text("High Cell Voltage", style: TextStyle(color: Colors.white70.withOpacity(0.65)),)),
        Container(height: 12,),
        Container(
            child: SixteenSegmentDisplay(
          value: sprintf("%0.3f", [low]),
          size: 4.0,
          backgroundColor: Colors.transparent,
          segmentStyle: RectSegmentStyle(
              enabledColor: Color(0xffedd711),
              disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
        )),
        Container(height: 20, child: Text("Low Cell Voltage", style: TextStyle(color: Colors.white70.withOpacity(0.65)),)),
        Container(height: 12,),
        Container(
            child: SixteenSegmentDisplay(
          //TODO:Ask team if we need more precision on this value
          value: sprintf("%0.1f", [packVoltSum]),
          size: 4.0,
          backgroundColor: Colors.transparent,
          segmentStyle: RectSegmentStyle(
              enabledColor: Color(0xffedd711),
              disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
        )),
        Container(height: 20, child: Text("Pack Voltage", style: TextStyle(color: Colors.white70.withOpacity(0.65)),)),
        Container(height: 12,),
        Container(
            child: SixteenSegmentDisplay(
          value: highTemp.toString(),
          size: 4.0,
          backgroundColor: Colors.transparent,
          segmentStyle: RectSegmentStyle(
              enabledColor: Color(0xffedd711),
              disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
        )),
        Container(height: 20, child: Text("High Temp ºC", style: TextStyle(color: Colors.white70.withOpacity(0.65)),)),
        Container(height: 12,),
        Container(
            child: SixteenSegmentDisplay(
          value: currentDraw.toString(),
          size: 4.0,
          backgroundColor: Colors.transparent,
          segmentStyle: RectSegmentStyle(
              enabledColor: Color(0xffedd711),
              disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
        )),
        //Signed Value from PID of BMS
        Container(height: 20, child: Text("Current Draw", style: TextStyle(color: Colors.white70.withOpacity(0.65)),))
      ]),
    );
  }
}
