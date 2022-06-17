import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SOCMeter extends StatefulWidget {

  @override createState() => _SOCMeterState();
}

class _SOCMeterState extends State<SOCMeter> {
  Stream _dB = FirebaseFirestore.instance.collection('VisibleTelemetry')
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots(includeMetadataChanges: true);
  double _soc = 82.8;

  void setSOC(QuerySnapshot val) {
    if (this.mounted)
    setState(() {val.docs.forEach((doc) {
      if (this.mounted)
        setState(() {
          _soc = doc['soc'];

        });
    });
    });
  }

  @override
  void initState() {
    super.initState();
    _dB.listen((soc) {setSOC(soc);});
  }
  @override
  Widget build(BuildContext context) {
    return SfLinearGauge(
        numberFormat: NumberFormat.percentPattern("en_US"),
        orientation: LinearGaugeOrientation.vertical,
        minimum: 0.0,
        maximum: 1.0,
        axisTrackStyle: LinearAxisTrackStyle(
            thickness: 10, color: Colors.white.withOpacity(0.05)),
        barPointers: [
          LinearBarPointer(
            enableAnimation: false,
            value: _soc / 100,
            edgeStyle: LinearEdgeStyle.endCurve,
            thickness: 8,
            color: Color(0xffedd711),
            borderColor: Color(0xff070b1a),
            borderWidth: 1.25,
          )
        ]);
  }
}