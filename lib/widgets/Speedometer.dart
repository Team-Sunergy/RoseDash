import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:segment_display/segment_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class Speedometer extends StatefulWidget {
  final bool timeOn;
  final Stream<int> mphStream;
  final Function(double) callback;
  Speedometer({required this.callback, required this.timeOn, required this.mphStream});
  //Speedometer({required this.mphStream, required this.timeOn});
  @override _SpeedometerState createState() => _SpeedometerState();
}
class _SpeedometerState extends State<Speedometer> {
  Stream _dB = FirebaseFirestore.instance.collection('adminSettings')
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots(includeMetadataChanges: true);
  int _targetSpeed = 0;
  double speed = 0;
  var speedometerImage = 'images/ROSE_logo.png';

  void setImage(speed, image){
    if (speed < 20) {
      image = 'images/ROSE_logo.png';
    }
    else if (speed < 20) {
      image = 'image/Yosef_dental.png';
    }
  }

  void setSpeed(Position pos) {
    if (this.mounted)
      setState(() {
        speed = pos.speed * 2.236936;
        widget.callback.call(speed);
      });
  }

  void setTargetSpeed(QuerySnapshot snapshot) {
    if (this.mounted)
      snapshot.docs.forEach((element) {
        setState(() {
          _targetSpeed = element['targetSpeed'];
          // TODO: Audible alert for new target speed
        });
      });
  }

  @override
  void initState() {
    super.initState();
    Geolocator.getPositionStream(locationSettings: LocationSettings(accuracy: LocationAccuracy.best)).listen((speed) {setSpeed(speed);});
    widget.callback.call(speed);
    //widget.mphStream.listen((event) {setSpeed(event);});
    _dB.listen((event) {setTargetSpeed(event);});
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [Expanded(flex: 1, child: SixteenSegmentDisplay(value: "\n" + speed.toInt().toString() + " MPH ", size: 4.5, segmentStyle: RectSegmentStyle(
        enabledColor: Colors.white,
        disabledColor: Color(0xffc2b11d).withOpacity(0.05)))), Container(height: 10),
      Expanded(flex: 8, child: SfRadialGauge(axes: <RadialAxis>[
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
                      angle: _speedAngle(speed),
                      child : Container(
                          width: 615.00,
                          height: 615.00,
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                              alignment: Alignment.centerRight,
                              filterQuality: FilterQuality.high,
                              colorFilter: ColorFilter.srgbToLinearGamma(),
                              image:
                              ExactAssetImage('images/rose_logo.png'),
                              fit: BoxFit.cover,
                              opacity: 0.4,
                            ),
                          )
                      ),
                    )
                  ],
                ),
              )
            ]
        ),
        RadialAxis(
          showAxisLine: false,
          showLabels: false,
          showTicks: false,
          radiusFactor: 0.85,
          minimum: 0,
          maximum: 81,
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
                enableAnimation: true),
            NeedlePointer(
                value: (_targetSpeed) / 1.0,
                onValueChanged: (double newValue) {
                  if (this.mounted)
                    setState(() {
                      _targetSpeed = newValue as int;
                    });
                },
                needleColor: Color(0xff3eff44).withOpacity(0.5),
                needleLength: 4,
                needleStartWidth: 0.5,
                needleEndWidth: 5,
                knobStyle: KnobStyle(
                    color: Colors.white,
                    borderColor: Color(0xff070b1a),
                    borderWidth: 0.006,
                    knobRadius: 0.017),
                enableAnimation: true)
          ],
        ),
        RadialAxis(
          centerX: 0.5,
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
                color: Color(0xffffffff)),
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
                color: Color(0xffffffff)),
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
                color: Color(0xffffffff)),
          ],
        ),
        RadialAxis(
            centerX: 0.495,
            showAxisLine: false,
            showLabels: true,
            showTicks: true,
            radiusFactor: 0.87,
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
                positionFactor: 0.6,
              ),
              // GaugeAnnotation(
              //   widget: Container(
              //     height: 40,
              //     child: Column(
              //       children: [
              //         SixteenSegmentDisplay(
              //             value: "Target: " + _targetSpeed.toString() + "\n",
              //             size: 1.25,
              //             backgroundColor: Colors.transparent,
              //             segmentStyle: RectSegmentStyle(
              //                 enabledColor: Colors.yellow,
              //                 disabledColor: Color(0xff635b0e).withOpacity(0.05))),
              //       ],
              //     ),
              //   ),
              //   angle: 85,
              //   positionFactor: 0.87,
              // ),
              GaugeAnnotation(
                widget: Container(
                  height: 200,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(width: 110,),
                          Material(
                            color: Colors.black,
                            child: widget.timeOn ? DigitalClock(
                            digitAnimationStyle: Curves.bounceInOut,
                            is24HourTimeFormat: false,
                            showSecondsDigit: false,
                            amPmDigitTextStyle: TextStyle(
                              color: Color(0xffc2b11d).withOpacity(0.5),
                              fontSize: 15,
                              fontFamily: "Schyler-Regular"
                            ),
                            secondDigitDecoration: BoxDecoration(color: Colors.transparent),
                            secondDigitTextStyle: TextStyle(
                              color: Color(0xffedd711),
                              fontSize: 15,
                            ),
                            hourMinuteDigitDecoration: BoxDecoration(color: Colors.transparent),
                            hourMinuteDigitTextStyle: TextStyle(
                              color: Color(0xffedd711),
                              fontSize: 30, //USED TO BE 16
                            ),
                            areaDecoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.transparent),
                            ),

                          )
                              : Container(),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                angle: 85,
                positionFactor: 1.1, //USED TO BE .97
              ),

            ]),

      ]))]);
  }
}

// Angle of speedo Yosef
double _speedAngle(double speed)
{
  if (speed < 30) { return 0.2; }
  else if (speed >= 30 && speed < 40) { return 0.275; }
  else { return 0.35; }
}