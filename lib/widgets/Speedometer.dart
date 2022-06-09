// @dart=2.9
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:segment_display/segment_display.dart';
import 'package:geolocator/geolocator.dart';

class Speedometer extends StatefulWidget {
  @override _SpeedometerState createState() => _SpeedometerState();
}
class _SpeedometerState extends State<Speedometer> {

  double speed = 0.0;
  void setSpeed(Position pos) {
    if (this.mounted)
    setState(() {speed = pos.speed;});
  }

  @override
  void initState() {
    super.initState();
    Geolocator.getPositionStream().listen((speed) {setSpeed(speed);});
  }
  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(axes: <RadialAxis>[
      RadialAxis(
          showAxisLine: false,
          showLabels: false,
          showTicks: false,
          radiusFactor: 1,
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Added image widget as an annotation
                  Container(
                      width: 250.00,
                      height: 250.00,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          alignment: Alignment.bottomLeft,
                          image:
                          ExactAssetImage('images/SunergyYosef-yellow.png'),
                          fit: BoxFit.fill,
                        ),
                      )),
                ],
              ),
            )
          ]),
      RadialAxis(
        showAxisLine: false,
        showLabels: false,
        showTicks: false,
        pointers: <GaugePointer>[
          NeedlePointer(
              value: speed,
              onValueChanged: (double newValue) {
                if (this.mounted)
                setState(() {
                  speed = newValue;
                });
              },
              needleColor: Color(0xffd9950b).withOpacity(1),
              needleLength: 4,
              needleStartWidth: 0.5,
              needleEndWidth: 5,
              tailStyle: TailStyle(
                  length: 0.0455,
                  width: 1.5,
                  borderWidth: 1,
                  borderColor: Color(0xff070b1a)),
              knobStyle: KnobStyle(
                  color: Colors.white,
                  borderColor: Color(0xff070b1a),
                  borderWidth: 0.006,
                  knobRadius: 0.017),
              enableAnimation: false)
        ],
      ),
      RadialAxis(
        useRangeColorForAxis: true,
        showAxisLine: false,
        showLabels: false,
        showTicks: false,
        radiusFactor: 1.05,
        ranges: <GaugeRange>[
          GaugeRange(
              startValue: 0,
              endValue: 20,
              startWidth: 0,
              endWidth: 10,
              color: Color(0xffc2b11d)),
          GaugeRange(
              startValue: 22,
              endValue: 42,
              startWidth: 5,
              endWidth: 15,
              color: Color(0xff03050a)),
          GaugeRange(
              startValue: 44,
              endValue: 64,
              startWidth: 7,
              endWidth: 20,
              color: Color(0xffedd711)),
          GaugeRange(
              startValue: 66,
              endValue: 86,
              startWidth: 20,
              endWidth: 20,
              color: Color(0xff03050a)),
          GaugeRange(
              startValue: 88,
              endValue: 100,
              startWidth: 10,
              endWidth: 20,
              color: Color(0xffc2b11d)),
        ],
      ),
      RadialAxis(
          showAxisLine: false,
          showLabels: true,
          showTicks: true,
          radiusFactor: 0.9,
          minimum: 0,
          maximum: 100,
          majorTickStyle: MajorTickStyle(
              color: Color(0xffc2b11d), dashArray: <double>[5, 5]),
          minorTickStyle: MinorTickStyle(color: Color(0xff635b0e)),
          axisLabelStyle: GaugeTextStyle(color: Color(0xffc2b11d)),
          axisLineStyle: AxisLineStyle(
            dashArray: <double>[5, 5],
          ),
          //color: Color(0xFFFF7676),),
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Container(
                child: SixteenSegmentDisplay(
                    value: speed.toInt().toString() + ' mph',
                    size: 2.5,
                    backgroundColor: Colors.transparent,
                    segmentStyle: RectSegmentStyle(
                        enabledColor: Colors.yellow,
                        disabledColor: Color(0xff635b0e).withOpacity(0.05))),
              ),
              angle: 85,
              positionFactor: 0.5,
            ),
            GaugeAnnotation(
              widget: Container(
                child: SixteenSegmentDisplay(
                    value: 'Range:828mi',
                    size: 1.25,
                    backgroundColor: Colors.transparent,
                    segmentStyle: RectSegmentStyle(
                        enabledColor: Colors.yellow,
                        disabledColor: Color(0xff635b0e).withOpacity(0.05))),
              ),
              angle: 85,
              positionFactor: 0.7,
            )
          ]),
    ]);
  }
}