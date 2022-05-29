// @dart=2.9
import 'dart:async';
import 'dart:convert';


import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:sprintf/sprintf.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:segment_display/segment_display.dart';

// Navigation Imports
import 'package:flutter_map/flutter_map.dart';
import "package:latlong2/latlong.dart" as latLng;



// Offline Maps
import 'package:cached_network_image/cached_network_image.dart';

// Custom Widgets
import '../widgets/Speedometer.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};
}

class HomePageState extends State<HomePage> {

  Speedometer speedo = Speedometer();
  Widget volt;
  double speed = 20.0;
  double _currentValue = 82.8;
  double _startMarkerValueLo = 32.2;
  double _startMarkerValueHi = 34.2;
  double _startSOCMarkerValue = 82.8;
  int _startHiTempMarkerValue = 31;
  double _packVoltSum = 0.0;
  double _startCurrentDraw = 10.0;
  double _startdeltaMarkerValue = 0.0;
  int _index = 0;
  List<BluetoothService> _services;
  BluetoothCharacteristic c;
  BluetoothDevice _connectedDevice;
  StreamSubscription<Object> reader;

  Widget voltWidget() {
    //PictureRecorder recorder = PictureRecorder();
    //Canvas canvas = Canvas(recorder);
    return Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Column(
              children: [
                Container(
                  //width: 150,
                  //color: Colors.red,
                    child: SixteenSegmentDisplay(
                      value: _startSOCMarkerValue.toString() + "%",
                      size: 4.0,
                      backgroundColor: Colors.transparent,
                      segmentStyle: RectSegmentStyle(
                          enabledColor: Color(0xffedd711),
                          disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
                    )),
                Container(height: 20, child: Text("State of Charge")),
                Container(
                    child: SixteenSegmentDisplay(
                      value: sprintf("%0.4f", [_startMarkerValueHi]),
                      size: 4.0,
                      backgroundColor: Colors.transparent,
                      segmentStyle: RectSegmentStyle(
                          enabledColor: Color(0xffedd711),
                          disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
                    )),
                Container(height: 20, child: Text("High Cell (Volt)")),
                Container(
                    child: SixteenSegmentDisplay(
                      value: sprintf("%0.4f", [_startMarkerValueLo]),
                      size: 4.0,
                      backgroundColor: Colors.transparent,
                      segmentStyle: RectSegmentStyle(
                          enabledColor: Color(0xffedd711),
                          disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
                    )),
                Container(height: 20, child: Text("Low Cell (Volt)")),
                Container(
                    child: SixteenSegmentDisplay(
                      //TODO:Ask team if we need more precision on this value
                      value: sprintf("%0.1f", [_packVoltSum]),
                      size: 4.0,
                      backgroundColor: Colors.transparent,
                      segmentStyle: RectSegmentStyle(
                          enabledColor: Color(0xffedd711),
                          disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
                    )),
                Container(height: 20, child: Text("Pack (Volt)")),
                Container(
                    child: SixteenSegmentDisplay(
                      value: _startHiTempMarkerValue.toString(),
                      size: 4.0,
                      backgroundColor: Colors.transparent,
                      segmentStyle: RectSegmentStyle(
                          enabledColor: Color(0xffedd711),
                          disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
                    )),
                Container(height: 20, child: Text("Hi Cell (ºCel)")),
                Container(
                    child: SixteenSegmentDisplay(
                      value: _startCurrentDraw.toString(),
                      size: 4.0,
                      backgroundColor: Colors.transparent,
                      segmentStyle: RectSegmentStyle(
                          enabledColor: Color(0xffedd711),
                          disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
                    )),
                //Signed Value from PID of BMS
                Container(height: 20, child: Text("Current Draw")),
              ],
            ),
            Container(
              height: 375,
              child: Row(
                children: [
                  Container(
                    width: 30,
                  ),
                  Container(
                    //height: 40,
                    //width: 20,
                      child: loHiVoltMeter()

                    //color: Colors.blue
                  ),
                  Container(
                    //height: 40,
                    width: 40,
                    //color: Colors.green
                  ),
                  Container(child: socMeter()),
                  Container(
                    //height: 40,
                    width: 20,
                    //color: Colors.green
                  ),
                  Container(child: hiTempMeter()),
                ],
              ),
            ),
          ],
        ),
        Container(
          height: 15,
          //width: 20,
        ),
        Container(
          //height: 20,
            width: 368,
            //color: Colors.pink
            child: deltaMeter()),
        Container(height: 0
          //color: Colors.green
        ),
      ])
    ]);
  }

  Widget loHiVoltMeter() {
    //TODO: Globalize Fields for Stateful behavior
    return SfLinearGauge(
      numberFormat: NumberFormat("#0.#v"),
      orientation: LinearGaugeOrientation.vertical,
      minimum: 3.50,
      maximum: 3.515,
      axisTrackStyle: LinearAxisTrackStyle(thickness: 2.5),
      markerPointers: [
        LinearWidgetPointer(
            enableAnimation: false,
            value: _startMarkerValueLo,
            position: LinearElementPosition.cross,
            child: Transform.rotate(
              angle: 90 * math.pi / 180,
              child: IconButton(
                icon: Icon(Icons.battery_4_bar_outlined,
                    color: Color(0xffc2b11d), size: 27),
                //onPressed: null,
              ),
            ),
            onChanged: (double value) {
              setState(() {
                _startMarkerValueLo = value;
              });
            }),
        LinearWidgetPointer(
            enableAnimation: false,
            value: _startMarkerValueHi,
            offset: 10,
            position: LinearElementPosition.cross,
            //offset: 10,
            child: Transform.rotate(
              angle: 90 * math.pi / 180,
              child: IconButton(
                icon: Icon(Icons.battery_6_bar_outlined,
                    color: Color(0xffedd711), size: 30),
                //onPressed: null,
              ),
            ),
            onChanged: (double value) {
              setState(() {
                _startMarkerValueHi = value;
              });
            }),
      ],
    );
  }

  Widget socMeter() {
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
            value: _startSOCMarkerValue / 100,
            edgeStyle: LinearEdgeStyle.endCurve,
            thickness: 8,
            color: Color(0xffedd711),
            borderColor: Color(0xff070b1a),
            borderWidth: 1.25,
          )
        ]);
  }

  Widget hiTempMeter() {
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
            value: _startHiTempMarkerValue.toDouble(),
            edgeStyle: LinearEdgeStyle.endCurve,
            thickness: 8,
            color: Color(0xffedd711),
            borderColor: Color(0xff070b1a),
            borderWidth: 1.25,
          )
        ]);
  }

  Widget deltaMeter() {
    //TODO: Formula for difference of hi/lo Volt
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
          value: _startdeltaMarkerValue,
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

  @override
  void initState() {
    speedo.setSpeed(speed);
    // Calling superclass initState
    super.initState();
    // Will be set to true on reconnect or 1st connect
    bool connected = false;
    // Reconnect to previously found device
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) async {
      connected = true;
      for (BluetoothDevice device in devices) {
        if (device.id.toString() == "F0:5E:CD:E2:58:5B") {
          try {
            await device.connect();
          } catch (e) {
            if (e.code != 'already_connected') {
              rethrow;
            }
          } finally {
            _services = await device.discoverServices();
            // Begin CAN communications
            print("before notify");
            notify();
            print("after notify");
            // Writing OBD2 requests
            //obd2Req("chillwave\n");
          }
        }
      }
    });
    if (!connected) {
      // Listen to scan results
      widget.flutterBlue.scanResults.listen((List<ScanResult> result) async {
        BluetoothDevice device;
        for (ScanResult r in result) {
          // Auto-Connect to HM-19
          if (r.device.id.toString() == "F0:5E:CD:E2:92:A1") {
            try {
              await r.device.connect();
            } catch (e) {
              if (e.code != 'already_connected') {
                rethrow;
              }
            } finally {
              // Supply ble services
              try {
                _services = await r.device.discoverServices();
              } catch (e) {
                print(e);
              }
              // Begin CAN communications
              notify();
              // OBD2 Request Call
              //obd2Req("nice\n");
            }
            setState(() {
              _connectedDevice = r.device;
            });
          }
        }
      });
      // Conduct Scan
      widget.flutterBlue.startScan();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget nav() {
    return FlutterMap(
      options: MapOptions(
        //center: latLng.LatLng(56.1304, 106.3468),
        center: latLng.LatLng(36.221366, -81.644684),
        zoom: 13.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://api.mapbox.com/styles/v1/svtappstate/cl3ewi1da003215o6b97pbc56/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3Z0YXBwc3RhdGUiLCJhIjoiY2wzYXBzOTgwMDgwYTNrbmo2bHFhYmszeCJ9.H8CwlSNpBsRe4fH7Y4QMPQ",
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              //point: latLng.LatLng(56.1304, 106.3468),
              point: latLng.LatLng(36.221366, -81.644684),
              builder: (ctx) =>
                  Container(
                  ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //TODO: Leave BT Settings and possible side menu
        body: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            child: Column(children: [
              Row(
                children: [
                  VerticalDivider(width: 200),
                  speedo,
                  VerticalDivider(width: 100),
                  Column(
                    children: [
                      Container(
                          height: 450,
                          width: 450,
                          child:
                          IndexedStack(
                            index: _index,
                            children: [
                              Container(margin: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 30),
                                  child: voltWidget()),
                              Center(child: ClipRRect(borderRadius: BorderRadius
                                  .horizontal(left: Radius.elliptical(150, 150),
                                  right: Radius.elliptical(150, 150)),
                                  child: Container(
                                      height: 500, width: 500, child: nav()))),
                              Center(child: voltWidget())
                            ],
                          )),
                      Container(height: 10,),
                      Row(
                          children: [
                            VerticalDivider(width: 15),
                            if (_index > 0) ElevatedButton(onPressed: () {
                              setState(() {
                                --_index;
                              });
                            },
                              child: Icon(
                                Icons.arrow_back_ios_new, color: Color(
                                  0xffedd711),),
                              style: ElevatedButton.styleFrom(primary: Color(
                                  0xff03050a),
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(18),),),
                            if (_index == 0) VerticalDivider(width: 65),
                            VerticalDivider(width: 150),
                            if (_index < 2 ) ElevatedButton(onPressed: () {
                              setState(() {
                                ++_index;
                              });
                            },
                              child: Icon(Icons.arrow_forward_ios, color: Color(
                                  0xffedd711),),
                              style: ElevatedButton.styleFrom(primary: Color(
                                  0xff03050a),
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(18),),),
                            if (_index == 2) VerticalDivider(width: 65),
                          ]
                      ),
                      Container(height: 10,),
                    ],
                  )
                ],
              ),
            ])
        )
    );
  }
  void obd2Req(val) {
    // Writing Request to Arduino:
    c.write(utf8.encode(val));
  }

  void notify() async {
    for (BluetoothService service in _services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        print(characteristic.uuid.toString());
        if (characteristic.uuid.toString() ==
            "0000ffe1-0000-1000-8000-00805f9b34fb") {
          c = characteristic;
          await c.setNotifyValue(true);

          reader = c.value.listen((event) {});

          reader.onData((data) {
            print("inside");
            print(utf8.decode(data));
            // This is where we receive our CAN Messages
            String message = utf8.decode(data);
            if (message.isNotEmpty) {
              print(message);
              if (message.substring(0, 1) != 'G') {
                _startSOCMarkerValue = int.parse(
                    message.substring(0, 2),
                    radix: 16) /
                    2;
                _startMarkerValueHi = int.parse(
                    message.substring(3, 7),
                    radix: 16) /
                    10000;
                _startMarkerValueLo = int.parse(
                    message.substring(8, 12),
                    radix: 16) /
                    10000;
                _packVoltSum = int.parse(
                    message.substring(13, 17),
                    radix: 16) /
                    100;
                _startHiTempMarkerValue = int.parse(
                    message.substring(18, 20),
                    radix: 16);
                _startdeltaMarkerValue =
                    _startMarkerValueHi - _startMarkerValueLo;
              } else {
                _startCurrentDraw = (int.parse(
                    message.substring(1, 3),
                    radix: 16)) *
                    0.1;
              }
            }
            //speedo = speedometer();
            if (speed < 100) speed++;

            speedo.setSpeed(speed.toDouble());
            //speedo.axes[1].pointers[0].onValueChanged((speed.toDouble()));
            //obd2Req("soc#");
          });
        }
      }
    }

    void startSpeed() {
      speedo.setSpeed(speed.toDouble());
      //speedo.axes[1].pointers[0].onValueChanged((speed.toDouble()));
    }
  }
}