
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class LoHiVoltMeter extends StatefulWidget {
  final Stream<double> lowStream;
  final Stream<double> highStream;
  LoHiVoltMeter({required this.lowStream, required this.highStream});
  @override _LoHiVoltMeterState createState() => _LoHiVoltMeterState();
}

class _LoHiVoltMeterState extends State<LoHiVoltMeter> {

  double low = 32.2;
  double high = 34.2;

  void setLow(val) {
    if (this.mounted)
    setState(() {low = val;});
  }

  void setHigh(val) {
    if (this.mounted)
    setState(() {high = val;});
  }

  @override
  void initState() {
    super.initState();
    widget.lowStream.listen((low) {setLow(low);});
    widget.highStream.listen((high) {setHigh(high);});
  }

  @override
  Widget build(BuildContext context) {
    return SfLinearGauge(
      numberFormat: NumberFormat("#0.000 v"),
      orientation: LinearGaugeOrientation.vertical,
      minimum: 3.50,
      maximum: 3.515,
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