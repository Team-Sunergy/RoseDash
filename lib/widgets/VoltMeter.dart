import 'dart:async';
import 'package:flutter/material.dart';


import 'package:bt01_serial_test/widgets/LoHiVoltMeter.dart';
import 'LoHiVoltMeter.dart';
import 'SOCMeter.dart';
import 'HighTempMeter.dart';
import 'DeltaMeter.dart';

class VoltMeter extends StatefulWidget {
  final Stream<double> socStream;
  final Stream<double> lowStream;
  final Stream<double> hiStream;
  final Stream<double> packVoltStream;
  final Stream<int> hiTempStream;
  final Stream<double> deltaStream;

  VoltMeter(
      {required this.socStream,
      required this.lowStream,
      required this.hiStream,
      required this.packVoltStream,
      required this.hiTempStream,
      required this.deltaStream});

  @override
  _VoltMeterState createState() => _VoltMeterState();
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



  void _setDelta() {
    _deltaController.add(high - low);
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
    widget.deltaStream.listen((event) {
      _setDelta();
    });
    widget.hiTempStream.listen((hiTemp) {
      _setHighTemp(hiTemp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Container(
              height: 394,
              child: Row(
                children: [
                  Container(
                    width: 50,
                  ),
                  Container(
                    //height: 40,
                    //width: 20,
                    child: LoHiVoltMeter(
                        lowStream: widget.lowStream,
                        highStream: widget.hiStream),
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
                  Container(
                      child:
                          HighTempMeter(highTempStream: widget.hiTempStream)),
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
