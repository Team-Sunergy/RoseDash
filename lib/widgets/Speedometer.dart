// @dart=2.9
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:segment_display/segment_display.dart';
import 'package:geolocator/geolocator.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';

class Speedometer extends StatefulWidget {
  bool timeOn = true;

  final Function(double) callback;
  Speedometer({this.callback, this.timeOn});
  @override _SpeedometerState createState() => _SpeedometerState();
}
class _SpeedometerState extends State<Speedometer> {
  int _targetSpeed = 0;
  double speed = 0;
  void setSpeed(Position pos) {
    if (this.mounted)
      setState(() {
        speed = pos.speed * 2.236936;
        widget.callback?.call(speed);
      });
  }

  @override
  void initState() {
    super.initState();
    Geolocator.getPositionStream(locationSettings: LocationSettings(accuracy: LocationAccuracy.best)).listen((speed) {setSpeed(speed);});
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
                  Transform.rotate(
                    angle: 0.2,
                    child : Container(
                        width: 270.00,
                        height: 270.00,
                        decoration: const BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                            alignment: Alignment.bottomLeft,
                            filterQuality: FilterQuality.high,
                            colorFilter: ColorFilter.srgbToLinearGamma(),
                            image:
                            ExactAssetImage('images/Yosef_dental.png'),
                            fit: BoxFit.fill,
                            opacity: 0.4,
                          ),
                        )),
                  )
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
        centerX: 0.51,
        useRangeColorForAxis: true,
        showAxisLine: false,
        showLabels: false,
        showTicks: false,
        radiusFactor: 1,
        ranges: <GaugeRange>[
          GaugeRange(
              startValue: 0,
              endValue: 16,
              startWidth: 0,
              endWidth: 5,
              color: Color(0xffc2b11d)),
          GaugeRange(
              startValue: 17,
              endValue: 32,
              startWidth: 5,
              endWidth: 10,
              color: Color(0xff03050a)),
          GaugeRange(
              startValue: 33,
              endValue: 48,
              startWidth: 10,
              endWidth: 13,
              color: Color(0xffedd711)),
          GaugeRange(
              startValue: 49,
              endValue: 64,
              startWidth: 13,
              endWidth: 16,
              color: Color(0xff03050a)),
          GaugeRange(
              startValue: 65,
              endValue: 80,
              startWidth: 16,
              endWidth: 20,
              color: Color(0xffc2b11d)),
          GaugeRange(
              startValue: 81,
              endValue: 100,
              startWidth: 20,
              endWidth: 23,
              color: Color(0xff03050a)),
        ],
      ),
      RadialAxis(
          showAxisLine: false,
          showLabels: true,
          showTicks: true,
          radiusFactor: 0.9,
          minimum: 0,
          maximum: 81,
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
                height: 40,
                child: Column(
                  children: [
                    SixteenSegmentDisplay(
                        value: "Target: " + _targetSpeed.toString(),
                        size: 1.25,
                        backgroundColor: Colors.transparent,
                        segmentStyle: RectSegmentStyle(
                            enabledColor: Colors.yellow,
                            disabledColor: Color(0xff635b0e).withOpacity(0.05))),
                  ],
                ),
              ),
              angle: 85,
              positionFactor: 0.73,
            ),
            GaugeAnnotation(
              widget: Container(
                height: 40,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(width: 165,),
                        widget.timeOn ? DigitalClock(
                          digitAnimationStyle: Curves.bounceInOut,
                          is24HourTimeFormat: false,
                          showSecondsDigit: false,
                          amPmDigitTextStyle: TextStyle(
                            color: Color(0xffc2b11d).withOpacity(0.5),
                            fontSize: 10,
                          ),
                          secondDigitDecoration: BoxDecoration(color: Colors.transparent),
                          secondDigitTextStyle: TextStyle(
                            color: Color(0xffedd711),
                            fontSize: 15,
                          ),
                          hourMinuteDigitDecoration: BoxDecoration(color: Colors.transparent),
                          hourMinuteDigitTextStyle: TextStyle(
                            color: Color(0xffedd711),
                            fontSize: 16,
                          ),
                          areaDecoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: Colors.transparent),
                          ),

                        )
                            : Container(),
                      ],
                    ),
                  ],
                ),
              ),
              angle: 85,
              positionFactor: 0.85,
            ),

          ]),

    ]);
  }
}