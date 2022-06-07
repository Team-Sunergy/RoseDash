import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';

class DeltaMeter extends StatefulWidget {

  final Stream<double> deltaStream;

  DeltaMeter({required this.deltaStream});

  @override createState() => _DeltaMeterState();
}

class _DeltaMeterState extends State<DeltaMeter> {

  double delta = 0.0;

  void setDelta(val) {
    if (this.mounted)
    setState(() {delta = val;});
  }

  @override
  void initState() {
    super.initState();
    widget.deltaStream.listen((delta) {setDelta(delta);});
  }

  @override
  Widget build(BuildContext context) {
    return SfLinearGauge(
      numberFormat: NumberFormat("#0.000Δv"),
      interval: 0.005,
      minorTicksPerInterval: 5,
      orientation: LinearGaugeOrientation.horizontal,
      minimum: 0.0,
      maximum: 0.015,
      axisTrackStyle: LinearAxisTrackStyle(
          thickness: 10, color: Colors.white.withOpacity(0.05)),
      barPointers: [
        LinearBarPointer(
          enableAnimation: false,
          value: delta,
          edgeStyle: LinearEdgeStyle.endCurve,
          thickness: 8,
          color: Color(0xffedd711),
          borderColor: Color(0xff070b1a),
          borderWidth: 1.25,
        )
      ],
      ranges: [
        LinearGaugeRange(
            startValue: 8,
            endValue: 10,
            startWidth: 5,
            endWidth: 5,
            color: Color(0xff7d7411)),
      ],
    );
  }
}