import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bt01_serial_test/widgets/LoHiVoltMeter.dart';
import 'LoHiVoltMeter.dart';
import 'SOCMeter.dart';
import 'HighTempMeter.dart';
import 'DeltaMeter.dart';

class VoltMeter extends StatefulWidget {
  @override
  _VoltMeterState createState() => _VoltMeterState();
}

class _VoltMeterState extends State<VoltMeter> {
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

  void setMetrics(QuerySnapshot snapshot) {
    snapshot.docs.forEach((doc) {
      if (this.mounted)
        setState(() {
          _setSOC(doc['soc']);
          _setLow(doc['lowVolt']);
          _setHigh(doc['highVolt']);
          _setDelta();
          _setHighTemp(doc['hiTemp']);
          _setPackVoltSum(doc['packVolt']);
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
                    child: LoHiVoltMeter(),
                    //color: Colors.blue
                  ),
                  Container(
                    //height: 40,
                    width: 40,
                    //color: Colors.green
                  ),
                  Container(child: SOCMeter()),
                  Container(
                    //height: 40,
                    width: 20,
                    //color: Colors.green
                  ),
                  Container(
                      child:
                          HighTempMeter()),
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
