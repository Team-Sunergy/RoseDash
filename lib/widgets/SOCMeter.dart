import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';

class SOCMeter extends StatefulWidget {
  final Stream<double> socStream;
  SOCMeter({required this.socStream});
  @override createState() => _SOCMeterState();
}

class _SOCMeterState extends State<SOCMeter> {

  double soc = 82.8;

  void setSOC(val) {
    if (this.mounted)
    setState(() {soc = val;});
  }

  @override
  void initState() {
    super.initState();
    widget.socStream.listen((soc) {setSOC(soc);});
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
            value: soc / 100,
            edgeStyle: LinearEdgeStyle.endCurve,
            thickness: 8,
            color: Color(0xffedd711),
            borderColor: Color(0xff070b1a),
            borderWidth: 1.25,
          )
        ]);
  }
}