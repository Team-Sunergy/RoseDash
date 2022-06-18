import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:segment_display/segment_display.dart';

class CenterIndicators extends StatefulWidget {

  final Stream<double> socStream;
  final Stream<double> lowStream;
  final Stream<double> hiStream;
  final Stream<double> packVoltStream;
  final Stream<int> hiTempStream;
  final Stream<double> currentDrawStream;

  CenterIndicators(
      {required this.socStream,
        required this.lowStream,
        required this.hiStream,
        required this.packVoltStream,
        required this.hiTempStream,
        required this.currentDrawStream});

  @override
  createState() => _CenterIndicatorsState();
}

class _CenterIndicatorsState extends State<CenterIndicators> {

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

  @override
  void initState() {
    super.initState();
    widget.socStream.listen((soc) {
      _setSOC(soc);
    });
    widget.lowStream.listen((low) {
      _setLow(low);
    });
    widget.hiStream.listen((hi) {
      _setHigh(hi);
    });
    widget.packVoltStream.listen((pvs) {
      _setPackVoltSum(pvs);
    });
    widget.hiTempStream.listen((hiTemp) {
      _setHighTemp(hiTemp);
    });
    widget.currentDrawStream.listen((cd) {
      _setCurrentDraw(cd);
    });
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
              enabledColor: highTemp < 35 ? Color(0xffedd711) : Color(0xfff72119),
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
              enabledColor: currentDraw <= 0 ? Color(0xff39ff14) : Color(0xfff72119) ,
              disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
        )),
        //Signed Value from PID of BMS
        Container(height: 20, child: Text("Current Draw", style: TextStyle(color: Colors.white70.withOpacity(0.65)),))
      ]),
    );
  }
}
