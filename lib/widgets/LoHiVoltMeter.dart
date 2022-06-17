
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

class LoHiVoltMeter extends StatefulWidget {
  @override _LoHiVoltMeterState createState() => _LoHiVoltMeterState();
}

class _LoHiVoltMeterState extends State<LoHiVoltMeter> {

  Stream _dB = FirebaseFirestore.instance.collection('VisibleTelemetry')
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots(includeMetadataChanges: true);

  double low = 32.2;
  double high = 34.2;

  void _setLow(val) {
    if (this.mounted)
    setState(() {low = val;});
  }

  void _setHigh(val) {
    if (this.mounted)
    setState(() {high = val;});
  }

  void setMetrics(QuerySnapshot snapshot) {
    snapshot.docs.forEach((doc) {
      if (this.mounted)
        setState(() {
          _setLow(doc['lowVolt']);
          _setHigh(doc['highVolt']);
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
    return SfLinearGauge(
      numberFormat: NumberFormat("#0.000 v"),
      orientation: LinearGaugeOrientation.vertical,
      minimum: 3.20,
      maximum: 4.0,
      axisTrackStyle: LinearAxisTrackStyle(thickness: 2.5),
      markerPointers: [
        LinearWidgetPointer(
            enableAnimation: false,
            value: low,
            position: LinearElementPosition.cross,
            child: Transform.rotate(
              angle: 90 * math.pi / 180,
              child: IconButton(
                onPressed: () => {},
                icon: Image.asset('images/outline_battery_4_bar_black_24dp.png',
                    color: Color(0xffc2b11d)),
                //onPressed: null,
              ),
            ),
            ),
        LinearWidgetPointer(
            enableAnimation: false,
            value: high,
            offset: 10,
            position: LinearElementPosition.cross,
            //offset: 10,
            child: Transform.rotate(
              angle: 90 * math.pi / 180,
              child: IconButton(
                onPressed: () => {},
                icon: Image.asset('images/outline_battery_6_bar_black_24dp.png',
                    color: Color(0xffedd711)),
                //onPressed: null,
              ),
            ),
            ),
      ],
    );
  }
}