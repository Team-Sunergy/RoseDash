//import 'dart:convert';
//import 'dart:ffi';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';
import '../utils.dart';

import 'package:sprintf/sprintf.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:segment_display/segment_display.dart';


// Navigation Imports
import 'package:flutter_map/flutter_map.dart';
import "package:latlong2/latlong.dart" as latLng;

// Offline Maps
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';


SfRadialGauge speedo;
Widget volt;
int speed = 0;
double _currentValue = 82.8;
double _startMarkerValueLo = 32.2;
double _startMarkerValueHi = 34.2;
double _startSOCMarkerValue = 82.8;
int _startHiTempMarkerValue = 31;
double _packVoltSum = 0.0;
double _startCurrentDraw = 10.0;
double _startdeltaMarkerValue = _startMarkerValueHi - _startMarkerValueLo;
int _index = 0;
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
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
                      value: sprintf("%0.3f",[_startMarkerValueHi]),
                      size: 4.0,
                      backgroundColor: Colors.transparent,
                      segmentStyle: RectSegmentStyle(
                          enabledColor: Color(0xffedd711),
                          disabledColor: Color(0xffc2b11d).withOpacity(0.05)),
                    )),
                Container(height: 20, child: Text("High Cell (Volt)")),
                Container(
                    child: SixteenSegmentDisplay(
                      value: sprintf("%0.3f",[_startMarkerValueLo]),
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
                      value: sprintf("%0.1f",[_packVoltSum]),
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

    /*markerPointers: [
        LinearWidgetPointer(value: _startHiTempMarkerValue.toDouble(),
            position: LinearElementPosition.cross,
            child: Transform.rotate(
              angle: 0 * math.pi / 180,
              child: IconButton(
                icon: Icon(Icons.thermostat_outlined, color: Colors.amberAccent, size: 23),
                //onPressed: null,
              ),
            ),
            onChanged: (double value) {
              setState(() {
                _startMarkerValueLo = value;
              });
            })
      ]);*/
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

  Widget speedometer() {
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
                      width: 200.00,
                      height: 200.00,
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
              value: _currentValue,
              onValueChanged: (double newValue) {
                setState(() {
                  _currentValue = newValue;
                });
              },
              needleColor: Colors.amberAccent,
              needleLength: 2,
              needleStartWidth: 0,
              needleEndWidth: 3,
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
                    value: _currentValue.toInt().toString() + ' mph',
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

  List<DeviceWithAvailability> devices = <DeviceWithAvailability>[];
  BluetoothDevice _selectedDevice;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothConnection connection;
  List<Message> messages = <Message>[];
  SharedPreferences _pref;
  List<CustomButton> customButtons = [];

  PageController _pageController = PageController(
    initialPage: 0,
  );
  TextEditingController _controller = TextEditingController();
  TabController _tabController;
  ScrollController _scrollController = ScrollController();

  String _address;
  String _name;
  String _messageBuffer = '';

  @override
  void initState() {
    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        _getDevices();
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });
    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });
    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    SharedPreferences.getInstance().then((SharedPreferences p) {
      _pref = p;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    _scrollController?.dispose();
    _tabController?.dispose();
    connection?.dispose();
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget nav() {
    return FlutterMap(
      mapController: MapController,
      options: MapOptions(
        center: latLng.LatLng(36.221366, -81.644684),
        zoom: 13.0,

      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://api.mapbox.com/styles/v1/svtappstate/cl3ewi1da003215o6b97pbc56/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3Z0YXBwc3RhdGUiLCJhIjoiY2wzYXBzOTgwMDgwYTNrbmo2bHFhYmszeCJ9.H8CwlSNpBsRe4fH7Y4QMPQ",
            tileProvider: StorageCachingTileProvider()
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
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Rose Dash Pre-Alpha"),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _startDevice();
              },
            ),
            Icon(btStateIcon(_bluetoothState)),
            IconButton(
              icon: _bluetoothState.isEnabled
                  ? Icon(Icons.toggle_on_outlined, color: Colors.green)
                  : Icon(Icons.toggle_off_outlined, color: Colors.grey),
              onPressed: () async {
                if (_bluetoothState.isEnabled) {
                  await FlutterBluetoothSerial.instance.requestDisable();
                } else {
                  await FlutterBluetoothSerial.instance.requestEnable();
                }
                setState(() {});
              },
            ),
            IconButton(
              icon: Icon(Icons.settings_bluetooth),
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
            ),
          ],
        ),
        body: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            child: Column(children: [
              Row(
                children: [
                  VerticalDivider(width: 200),
                  speedo = speedometer(),
                  VerticalDivider(width: 100),
                  Column(
                    children: [
                      Container(
                          height: 450,
                          width: 450,
                          child:
                          IndexedStack(
                            index: _index,
                            children: [Container(margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30), child:voltWidget()), Center(child: ClipRRect(borderRadius: BorderRadius.horizontal(left: Radius.elliptical(150, 150), right: Radius.elliptical(150, 150)), child: Container(height: 500, width: 500, child: nav()))), Center(child:voltWidget())],
                          )),
                      Container(height: 10,),
                      Row(
                        children: [
                          VerticalDivider(width:15),
                          if (_index > 0) ElevatedButton(onPressed: () { setState(() {--_index;});}, child: Icon(Icons.arrow_back_ios_new, color: Color(0xffedd711),), style: ElevatedButton.styleFrom(primary: Color(0xff03050a), shape: CircleBorder(), padding: EdgeInsets.all(18),),),
                          if (_index == 0) VerticalDivider(width: 65),
                          VerticalDivider(width: 150),
                          if (_index < 2 ) ElevatedButton(onPressed: () { setState(() {++_index;});}, child: Icon(Icons.arrow_forward_ios, color: Color(0xffedd711),), style: ElevatedButton.styleFrom(primary: Color(0xff03050a), shape: CircleBorder(), padding: EdgeInsets.all(18),),),
                          if (_index == 2) VerticalDivider(width: 65),
                        ]
                      ),
                      Container(height: 10,),
                    ],
                  )
                ],
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: EdgeInsets.only(bottom: 5),
                  padding: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.teal,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: devices.length,
                          itemBuilder: (context, i) {
                            return ListTile(
                              dense: true,
                              leading: Icon(Icons.devices),
                              title:
                              Text(devices[i].device.name ?? "Unknown.."),
                              subtitle:
                              Text(devices[i].device.address.toString()),
                              trailing:
                              Text(devices[i].device.bondState.stringValue),
                              onTap: () {
                                if (devices[i].isPaired == true) {
                                  setState(() {
                                    _selectedDevice = devices[i].device;
                                    //print(devices[i].name);
                                    connection?.dispose();
                                    _startConnection();
                                  });
                                } else {
                                  FlutterBluetoothSerial.instance
                                      .bondDeviceAtAddress(
                                      devices[i].device.address)
                                      .then((bool value) {
                                    devices[i].isPaired = value;
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // List of received messages
              Expanded(
                flex: 6,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.teal,
                      width: 1,
                    ),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      //speed = int.parse(messages[i].text.substring(0, 2), radix: 16);
                      if (messages[i].text.isNotEmpty) {
                        if (messages[i].text[0] != 'G') {
                          _startSOCMarkerValue = int.parse(
                              messages[i].text.substring(0, 2),
                              radix: 16) /
                              2;
                          _startMarkerValueHi = int.parse(
                              messages[i].text.substring(3, 7),
                              radix: 16) /
                              10000;
                          _startMarkerValueLo = int.parse(
                              messages[i].text.substring(8, 12),
                              radix: 16) /
                              10000;
                          _packVoltSum = int.parse(
                              messages[i].text.substring(13, 17),
                              radix: 16) /
                              100;
                          _startHiTempMarkerValue = int.parse(
                              messages[i].text.substring(18, 20),
                              radix: 16);
                          _startdeltaMarkerValue =
                              _startMarkerValueHi - _startMarkerValueLo;
                        } else {
                          _startCurrentDraw = (int.parse(
                              messages[i].text.substring(1, 3),
                              radix: 16)) *
                              0.1;
                        }
                        return Text(messages[i].text);
                      }
                      return Text("${messages[i].name} -> ${messages[i].text}");
                    },
                  ),
                ),
              ),
              // Send message to a paired device
              Expanded(
                flex: 6,
                child: Container(
                  child: Column(
                    children: [
                      Container(height: 10),
                      _selectedDevice == null
                          ? Text("No Device Selected")
                          : Text(
                          "Connected to ${_selectedDevice
                              .name} ::: ${_selectedDevice.address}"),
                    ],
                  ),
                ),
              )
            ])));
  }

  void _getDevices() {
    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) =>
          DeviceWithAvailability(
            device,
            DeviceAvailability.maybe,
          )
            ..isPaired = true,
        )
            .toList();
      });
    });
  }

  void _startDevice() {
    for (DeviceWithAvailability d in devices) {
      if (d.isPaired == false) {
        devices.remove(d);
      }
    }
    FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        bool isPaired = false;
        for (DeviceWithAvailability d in devices) {
          if (d.device == r.device) {
            d.availability = DeviceAvailability.yes;
            d.rssi = r.rssi;
            isPaired = true;
          }
        }
        if (!isPaired) {
          DeviceWithAvailability d =
          DeviceWithAvailability(r.device, DeviceAvailability.yes, r.rssi);
          d.isPaired = false;
          devices.add(d);
        }
      });
    }).onDone(() {
      for (DeviceWithAvailability d in devices) {
        if (d.availability == DeviceAvailability.maybe) {
          d.availability = DeviceAvailability.no;
        }
      }
    });
  }

  void _startConnection() {
    startSpeed();
    BluetoothConnection.toAddress(_selectedDevice.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      connection.input.listen(_onDataReceived).onDone(() {
        if (this.mounted) {
          setState(() {});
        }
      });
      setState(() {});
    }).catchError((error) {
      print('Cannot connect, exception occurred');
      print(error);
      _selectedDevice = null;
      connection?.dispose();
    });
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;
    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }
    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          Message(
            _selectedDevice.name ?? "Unknown",
            backspacesCounter > 0
                ? _messageBuffer
                .substring(0, _messageBuffer.length - backspacesCounter)
                .trim()
                : (_messageBuffer + dataString.substring(0, index)).trim(),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString).trim();
    }
    speedo = speedometer();
    speedo.axes[1].pointers[0].onValueChanged((speed.toDouble()));
    pollFaults();
  }

  void startSpeed() {
    speedo = speedometer();
    speedo.axes[1].pointers[0].onValueChanged((speed.toDouble()));
  }

  Future pollFaults() async {
    connection.output.add(ascii.encode("ptc#"));
    await connection.output.allSent;
  }
}

class StorageCachingTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(Coords<num> coords, TileLayerOptions options) {
    FMTCImageProvider(
      provider: this,
      options: options,
      coords: coords,
      httpClient:  'https://api.mapbox.com/v4/svtappstate.b0xrcr0g.json?access_token=pk.eyJ1Ijoic3Z0YXBwc3RhdGUiLCJhIjoiY2wzYXBzOTgwMDgwYTNrbmo2bHFhYmszeCJ9.H8CwlSNpBsRe4fH7Y4QMPQ',
    );    throw UnimplementedError();
  }
  
  
  
}
