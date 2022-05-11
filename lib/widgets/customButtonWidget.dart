import 'package:flutter/material.dart';

import '../models.dart';
import 'gameButton.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

Widget customButtonWidget(CustomButton b, dynamic onTap)
{
  return SfRadialGauge(
      title: GaugeTitle(
          text: 'Speedometer',
          textStyle:
          const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      axes: <RadialAxis>[
        RadialAxis(minimum: 0, maximum: 150, ranges: <GaugeRange>[
          GaugeRange(
              startValue: 0,
              endValue: 50,
              color: Colors.green,
              startWidth: 10,
              endWidth: 10),
          GaugeRange(
              startValue: 50,
              endValue: 100,
              color: Colors.orange,
              startWidth: 10,
              endWidth: 10),
          GaugeRange(
              startValue: 100,
              endValue: 150,
              color: Colors.red,
              startWidth: 10,
              endWidth: 10)
        ], pointers: <GaugePointer>[
          NeedlePointer(value: 90)
        ], annotations: <GaugeAnnotation>[
          GaugeAnnotation(
              widget: Container(
                  child: const Text('90.0',
                      style: TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold))),
              angle: 90,
              positionFactor: 0.5)
        ])
      ]);
}

/**
Widget customButtonWidget(CustomButton b, dynamic onTap) {
  if (b.type == 0) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(b.name, textScaleFactor: 2.0),
        gameButton("OFF", (TapDownDetails details) {
          onTap(b.val1);
        }),
        gameButton("ON ", (TapDownDetails details) {
          onTap(b.val2);
        }),
      ],
    );
  } else if (b.type == 1) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        gameButton(b.name, (TapDownDetails details) {
          onTap(b.val1);
        })
      ],
    );
  } else {
    return Container();
  }
}**/
