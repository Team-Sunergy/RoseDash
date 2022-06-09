// @dart=2.9
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

// BLE Library
import 'package:flutter_blue/flutter_blue.dart';

// Custom Widgets
import '../widgets/CenterIndicators.dart';
import './FullScreenNav.dart';
import '../widgets/Nav.dart';
import '../widgets/Speedometer.dart';
import '../widgets/VoltMeter.dart';
import '../widgets/AddBMSData.dart';
import '../widgets/TroubleCodes.dart';

// Location Streaming
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};
}

class HomePageState extends State<HomePage> {
  StreamController<int> _ctcControllerZero = StreamController<int>.broadcast();
  StreamController<int> _ctcControllerOne = StreamController<int>.broadcast();
  StreamController<int> _ctcControllerTwo = StreamController<int>.broadcast();
  StreamController<int> _ctcControllerThree = StreamController<int>.broadcast();
  StreamController<int> _ctcControllerFour = StreamController<int>.broadcast();
  StreamController<double> _socController = StreamController<double>.broadcast();
  StreamController<double> _lowController = StreamController<double>.broadcast();
  StreamController<double> _hiController = StreamController<double>.broadcast();
  StreamController<double> _packVoltSumController = StreamController<double>.broadcast();
  StreamController<double> _currentDrawController = StreamController<double>.broadcast();
  StreamController<int> _hiTempController = StreamController<int>.broadcast();
  StreamController<double> _deltaController = StreamController<double>.broadcast();
  // This is for the IndexedStack
  int _leftIndex = 0;
  int _rightIndex = 0;
  List<BluetoothService> _services;
  BluetoothCharacteristic c;
  BluetoothDevice _connectedDevice;
  StreamSubscription<Object> reader;
  Nav navInstance;


  @override
  void initState() {
    // Calling superclass initState
    super.initState();
    navInstance = new Nav();
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
            //print("before notify");
            notify();
            //print("after notify");
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
            if (this.mounted)
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
  Widget build(BuildContext context) {
    return Scaffold(
      //TODO: Leave BT Settings and possible side menu
        body: Column(children: [
          Container(height: 100,),
          Row(
            children: [
              VerticalDivider(width: 100),
              Column (
                children: [
              Container(
                  height: 450,
                  width: 450,
                  child:
                  IndexedStack(
                    index: _leftIndex,
                    children: [Container(margin: EdgeInsets.symmetric(
                        vertical: 0, horizontal: 0),
                        child: Speedometer()),
                      Center(child: AddBMSData(socStream: _socController.stream,
                        lowStream: _lowController.stream,
                        hiStream: _hiController.stream,
                        packVoltStream: _packVoltSumController.stream,
                        currentDrawStream: _currentDrawController.stream,
                        deltaStream: _deltaController.stream,
                        hiTempStream: _hiTempController.stream,)),
                      Center(child: TroubleCodes(tcStream0: _ctcControllerZero.stream,
                                                 tcStream1: _ctcControllerOne.stream,
                                                 tcStream2: _ctcControllerTwo.stream,
                                                 tcStream3: _ctcControllerThree.stream,
                                                 tcStream4: _ctcControllerFour.stream,))

                    ],
                  )),

                  Container(margin: EdgeInsets.symmetric(vertical: 10,),
                    child: Row(children: [Icon(IconData(0xe7ce, fontFamily: 'MaterialIcons'),
                        size: 48, semanticLabel: "Aux Pack LOW"), Container(width: 50),
                      Icon(IconData(0xe6cc, fontFamily: 'MaterialIcons'),
                        size: 48, semanticLabel: "Battery Fault",)]),
                  ), // BPS fault and Aux low indicator
                  Row(
                      children: [
                        VerticalDivider(width: 15),
                        if (_leftIndex > 0) ElevatedButton(onPressed: () {
                          setState(() {
                            --_leftIndex;
                          });
                        },
                          child: Icon(
                            Icons.arrow_back_ios_new, color: Color(
                              0xffedd711),),
                          style: ElevatedButton.styleFrom(primary: Color(
                              0xff03050a),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(18),),),
                        if (_leftIndex == 0) VerticalDivider(width: 65),
                        VerticalDivider(width: 150),
                        if (_leftIndex < 2 ) ElevatedButton(onPressed: () {
                          setState(() {
                            ++_leftIndex;
                          });
                        },
                          child: Icon(Icons.arrow_forward_ios, color: Color(
                              0xffedd711),),
                          style: ElevatedButton.styleFrom(primary: Color(
                              0xff03050a),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(18),),),
                        if (_leftIndex == 2) VerticalDivider(width: 65),
                      ]
                  ),
                ],
              ),
              VerticalDivider(width: 70),
              CenterIndicators(socStream: _socController.stream,
                               hiStream: _hiController.stream,
                               lowStream: _lowController.stream,
                               packVoltStream: _packVoltSumController.stream,
                               hiTempStream: _hiTempController.stream,
                               currentDrawStream: _currentDrawController.stream,),
              VerticalDivider(width: 50),
              Column(
                children: [
                  Container(height: 10,),
                  Container(
                      height: 450,
                      width: 450,
                      child:
                      IndexedStack(
                        index: _rightIndex,
                        children: [
                          Container(margin: EdgeInsets.symmetric(
                              vertical: 0, horizontal: 30),
                              child: VoltMeter(socStream: _socController.stream,
                                               lowStream: _lowController.stream,
                                               hiStream: _hiController.stream,
                                               packVoltStream: _packVoltSumController.stream,
                                               deltaStream: _deltaController.stream,
                                               hiTempStream: _hiTempController.stream,)),
                          Center(child: ClipRRect(borderRadius: BorderRadius
                              .horizontal(left: Radius.elliptical(150, 150),
                              right: Radius.elliptical(150, 150)),
                              child: Container(
                                  height: 500, width: 500, child: navInstance))),
                          Center(child: VoltMeter(socStream: _socController.stream,
                                                  lowStream: _lowController.stream,
                                                  hiStream: _hiController.stream,
                                                  packVoltStream: _packVoltSumController.stream,
                                                  deltaStream: _deltaController.stream,
                                                  hiTempStream: _hiTempController.stream,))
                        ],
                      )),
                  Container(height: 10,),
                  Row(
                      children: [
                        VerticalDivider(width: 15),
                        if (_rightIndex > 0) ElevatedButton(onPressed: () {
                          setState(() {
                            --_rightIndex;
                          });
                        },
                          child: Icon(
                            Icons.arrow_back_ios_new, color: Color(
                              0xffedd711),),
                          style: ElevatedButton.styleFrom(primary: Color(
                              0xff03050a),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(18),),),
                        if (_rightIndex == 0) VerticalDivider(width: 65),
                        if (_rightIndex != 1)
                          VerticalDivider(width: 150),
                        if (_rightIndex == 1)
                          VerticalDivider(width: 44,),
                        if (_rightIndex == 1)
                           ElevatedButton(onPressed: () {
                            setState(() {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenNav()),);
                            });
                          },
                            child: Icon(Icons.fullscreen, color: Color(
                                0xffedd711), size: 40,),
                            style: ElevatedButton.styleFrom(primary: Color(
                                0xff03050a),
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(11),),),
                        if (_rightIndex == 1)
                          VerticalDivider(width: 44),
                        if (_rightIndex < 2 ) ElevatedButton(onPressed: () {
                          setState(() {
                            ++_rightIndex;
                          });
                        },
                          child: Icon(Icons.arrow_forward_ios, color: Color(
                              0xffedd711),),
                          style: ElevatedButton.styleFrom(primary: Color(
                              0xff03050a),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(18),),),
                        if (_rightIndex == 2) VerticalDivider(width: 65),
                      ]
                  ),
                  Container(height: 10,),
                ],
              )
            ],
          ),
        ])
    );
  }
  void obd2Req(val) async{
    // Writing Request to Arduino:
    await c.write(utf8.encode(val), withoutResponse: true);
  }

  void notify() async {
    for (BluetoothService service in _services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        //print(characteristic.uuid.toString());
        if (characteristic.uuid.toString() ==
            "0000ffe1-0000-1000-8000-00805f9b34fb") {
          c = characteristic;
          await c.setNotifyValue(true);

          reader = c.value.listen((event) {});

          reader.onData((data) async{
            //print(utf8.decode(data));
            // This is where we receive our CAN Messages
            String message = utf8.decode(data);
            if (message.isNotEmpty) {
              //print(message);
              if (message[0] == 'C') {
                int tc0 = 0;
                int tc1 = 0;
                int tc2 = 0;
                int tc3 = 0;
                int tc4 = 0;
                int count = 0;
                print("\n\ninside CTC block\n\n");
                for (int i = 1; i < message.length; i += 2) {
                  if (count == 0) {
                    tc0 = int.parse(message.substring(1, 3), radix: 16);
                    _ctcControllerZero.add(tc0);
                  }
                  else if (count == 1) {
                    tc1 = int.parse(message.substring(3, 5), radix: 16);
                    _ctcControllerOne.add(tc1);
                  }
                  else if (count == 2) {
                    tc2 = int.parse(message.substring(5, 7), radix: 16);
                    _ctcControllerTwo.add(tc2);
                  }
                  else if (count == 3) {
                    tc3 = int.parse(message.substring(7, 9), radix: 16);
                    _ctcControllerThree.add(tc3);
                  }
                  else if (count == 4) {
                    tc4 = int.parse(message.substring(9, 11), radix: 16);
                    _ctcControllerFour.add(tc4);
                  }
                  count++;
                }
              }
              else if (message[0] == 'G') {
                _socController.add(int.parse(
                    message.substring(1, 3),
                    radix: 16) /
                    2);
                _hiController.add(int.parse(
                    message.substring(4, 8),
                    radix: 16) /
                    10000);
                _lowController.add(int.parse(
                    message.substring(9, 13),
                    radix: 16) /
                    10000);
                _packVoltSumController.add(int.parse(
                    message.substring(14, 18),
                    radix: 16) /
                    100);
                _hiTempController.add(int.parse(
                    message.substring(19, 21),
                    radix: 16));
                // Arithmetic is performed in VoltMeter Widget
                _deltaController.add(0);
              } else if (message[0] == 'H') {
                _currentDrawController.add((int.parse(
                    message.substring(1, 3),
                    radix: 16)) *
                    0.1);
              }
              await obd2Req("ctc#");
            }
          });
        }
      }
    }
  }
}