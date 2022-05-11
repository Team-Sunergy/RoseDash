import 'package:flutter/material.dart';

import 'gameButton.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
double _currentValue = 50.0;

Widget speedometer(dynamic onTap)
{
  return SfRadialGauge(enableLoadingAnimation: true, animationDuration: 4500,
      title: GaugeTitle(
          text: 'Speed',
          textStyle:
          const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xff6df1d8))),
      axes: <RadialAxis>[
        RadialAxis(minimum: 0, maximum: 100, ranges: <GaugeRange>[
          GaugeRange(
              startValue: 0,
              endValue: 33,
              color: Color(0xffffd319),
              startWidth: 10,
              endWidth: 10),
          GaugeRange(
              startValue: 33,
              endValue: 66,
              color: Color(0xffff901f),
              startWidth: 10,
              endWidth: 10),
          GaugeRange(
              startValue: 66,
              endValue: 100,
              color: Color(0xffff2975),
              startWidth: 10,
              endWidth: 10)
        ], pointers: <GaugePointer>[
          NeedlePointer(value: _currentValue,
                        //onValueChanged: (double newValue) {
                        //setState(() {
                        //    _currentValue = newValue;
                        //  });
                        //},
                        needleColor: Color(0xfff222ff),
                        knobStyle: KnobStyle(color: Color(0xff8c1eff), borderColor: Color(0xff6df1d8), borderWidth: 0.01),
                        enableAnimation: true)

        ], annotations: <GaugeAnnotation>[
          GaugeAnnotation(
              widget: Container(
                  child: const Text('50',
                      style: TextStyle(color: Color(0xff6df1d8),
                          fontSize: 25, fontWeight: FontWeight.bold))),
              angle: 90,
              positionFactor: 0.5)
        ])
      ]);
/**
Widget gamePad(dynamic onTap) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          gameButton("^", (TapDownDetails details) {
            onTap(0);
          })
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          gameButton("<", (TapDownDetails details) {
            onTap(2);
          }),
          Container(width: 30),
          gameButton("O", (TapDownDetails details) {
            onTap(4);
          }),
          Container(width: 30),
          gameButton(">", (TapDownDetails details) {
            onTap(3);
          }),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          gameButton("⌄", (TapDownDetails details) {
            onTap(1);
          })
        ],
      ),
    ],
  );**/
}
