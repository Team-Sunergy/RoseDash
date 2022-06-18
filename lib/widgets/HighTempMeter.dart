import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';

class HighTempMeter extends StatefulWidget {
  final Stream<int> highTempStream;
  HighTempMeter({required this.highTempStream});
  @override createState() => _HighTempMeterState();
}

class _HighTempMeterState extends State<HighTempMeter> {

  int _highTemp = 0;

  void setHighTemp(val) {
    if (this.mounted)
    setState(() {_highTemp = val;});
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
        minorTicksPerInterval: 5,
        orientation: LinearGaugeOrientation.vertical,
        minimum: 21,
        maximum: 72,
        axisTrackStyle:
        LinearAxisTrackStyle(thickness: 10, color: Colors.transparent),
        barPointers: [
          LinearBarPointer(
            enableAnimation: false,
            value: _highTemp.toDouble(),
            edgeStyle: LinearEdgeStyle.endCurve,
            thickness: 8,
            color: _highTemp < 35 ? Color(0xffedd711) : Color(0xfff72119),
            borderColor: Color(0xff070b1a),
            borderWidth: 1.25,
          )
        ]);
  }
}