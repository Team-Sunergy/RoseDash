import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';

class HighTempMeter extends StatefulWidget {
  final Stream<int> highTempStream;
  HighTempMeter({required this.highTempStream});
  @override createState() => _HighTempMeterState();
}

class _HighTempMeterState extends State<HighTempMeter> {

  int highTemp = 0;

  void setHighTemp(val) {
    if (this.mounted)
    setState(() {highTemp = val;});
  }

  @override
  void initState() {
    super.initState();
    widget.highTempStream.listen((highTemp) {setHighTemp(highTemp);});
  }
  @override
  Widget build(BuildContext context) {
    return SfLinearGauge(
        numberFormat: NumberFormat("##0º"),
        interval: 3,
        minorTicksPerInterval: 10,
        orientation: LinearGaugeOrientation.vertical,
        minimum: 0.0,
        maximum: 45.0,
        axisTrackStyle:
        LinearAxisTrackStyle(thickness: 10, color: Colors.transparent),
        barPointers: [
          LinearBarPointer(
            enableAnimation: false,
            value: highTemp.toDouble(),
            edgeStyle: LinearEdgeStyle.endCurve,
            thickness: 8,
            color: Color(0xffedd711),
            borderColor: Color(0xff070b1a),
            borderWidth: 1.25,
          )
        ]);
  }
}