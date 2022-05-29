import 'dart:async';
import 'package:bt01_serial_test/widgets/LoHiVoltMeter.dart';
import 'package:flutter/material.dart';
import 'package:segment_display/segment_display.dart';
import 'package:sprintf/sprintf.dart';
import 'LoHiVoltMeter.dart';
import 'SOCMeter.dart';
import 'HighTempMeter.dart';
import 'DeltaMeter.dart';

class VoltMeter extends StatefulWidget {
  final Stream<double> socStream;
  final Stream<double> lowStream;
  final Stream<double> hiStream;
  final Stream<double> packVoltStream;
  final Stream<double> currentDrawStream;
  final Stream<double> deltaStream;
  final Stream<int> hiTempStream;

  VoltMeter({required this.socStream, required this.lowStream,
              required this.hiStream, required this.packVoltStream,
              required this.currentDrawStream, required this.hiTempStream,
              required this.deltaStream});

  @override _VoltMeterState createState() => _VoltMeterState();
}

class _VoltMeterState extends State<VoltMeter> {

  double soc = 82.8;
  double low = 32.2;
  double high = 34.2;
  double packVoltSum = 0.0;
  double currentDraw = 10.0;
  int highTemp = 31;
  StreamController<double> _deltaController = StreamController<double>();


  void _setSOC(val) {
    setState(() {soc = val;});
  }

  void _setLow(val) {
    setState(() {low = val;});
  }

  void _setHigh(val) {
    setState(() {high = val;});
  }

  void _setPackVoltSum(val) {
    setState(() {packVoltSum = val;});
  }

  void _setHighTemp(val) {
    setState(() {highTemp = val;});
  }

  void _setCurrentDraw(val) {
    setState(() {currentDraw = val;});
  }

  void _setDelta() {
    _deltaController.add(high - low);
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
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Column(
                children: [
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
                  Container(height: 20, child: Text("State of Charge")),
                  Container(
                      child: SixteenSegmentDisplay(
                        value: sprintf("%0.3f", [high]),
                        size: 4.0,
                        backgroundColor: Colors.transparent,
                        segmentStyle: RectSegmentStyle(
                            enabledColor: Color(0xffedd711),
                            disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
                      )),
                  Container(height: 20, child: Text("High Cell (Volt)")),
                  Container(
                      child: SixteenSegmentDisplay(
                        value: sprintf("%0.3f", [low]),
                        size: 4.0,
                        backgroundColor: Colors.transparent,
                        segmentStyle: RectSegmentStyle(
                            enabledColor: Color(0xffedd711),
                            disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
                      )),
                  Container(height: 20, child: Text("Low Cell (Volt)")),
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
                  Container(height: 20, child: Text("Pack (Volt)")),
                  Container(
                      child: SixteenSegmentDisplay(
                        value: highTemp.toString(),
                        size: 4.0,
                        backgroundColor: Colors.transparent,
                        segmentStyle: RectSegmentStyle(
                            enabledColor: Color(0xffedd711),
                            disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
                      )),
                  Container(height: 20, child: Text("Hi Cell (ºCel)")),
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
                  Container(height: 20, child: Text("Current Draw")),
                ],
              ),
              Container(
                height: 375,
                child: Row(
                  children: [
                    Container(
                      width: 30,
                    ),
                    Container(
                      //height: 40,
                      //width: 20,
                        child: LoHiVoltMeter(lowStream: widget.lowStream, highStream: widget.hiStream),
                      //color: Colors.blue
                    ),
                    Container(
                      //height: 40,
                      width: 40,
                      //color: Colors.green
                    ),
                    Container(child: SOCMeter(socStream: widget.socStream)),
                    Container(
                      //height: 40,
                      width: 20,
                      //color: Colors.green
                    ),
                    Container(child: HighTempMeter(highTempStream: widget.hiTempStream)),
                  ],
                ),
              ),
            ],
          ),
          Container(
            height: 15,
            //width: 20,
          ),
          Container(
            //height: 20,
              width: 368,
              //color: Colors.pink
              child: DeltaMeter(deltaStream: _deltaController.stream)),
          Container(height: 0
            //color: Colors.green
          ),
        ])
      ]);
    }
}