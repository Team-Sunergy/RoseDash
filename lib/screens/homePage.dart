// @dart=2.9
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:characters/characters.dart';
// BLE Library
import 'package:flutter_blue/flutter_blue.dart';

// Custom Widgets
import '../widgets/CenterIndicators.dart';
import '../widgets/Warnings.dart';
//import './FullScreenNav.dart';
//import '../widgets/Nav.dart';
import '../widgets/Speedometer.dart';
import '../widgets/VoltMeter.dart';
import '../widgets/AddBMSData.dart';
import '../widgets/TroubleCodes.dart';
import '../widgets/NavDirections.dart';

// Location Streaming
//import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  // This is for the IndexedStack
  static int leftIndex = 0;
  static int rightIndex = 0;
  @override
  State<StatefulWidget> createState() => HomePageState();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};
}
class UnderHood {
  int cellId;
  double instV;
  bool isShunting;
  double intRes;
  double openV;
}

class HomePageState extends State<HomePage> {
  StreamController<Set<String>> _ctcController = StreamController<Set<String>>.broadcast();
  StreamController<Set<String>> _ptcController = StreamController<Set<String>>.broadcast();
  StreamController<String> _apwController = StreamController<String>.broadcast();
  StreamController<double> _socController = StreamController<double>.broadcast();
  StreamController<double> _lowController = StreamController<double>.broadcast();
  StreamController<double> _hiController = StreamController<double>.broadcast();
  StreamController<double> _packVoltSumController = StreamController<double>.broadcast();
  StreamController<double> _currentDrawController = StreamController<double>.broadcast();
  StreamController<int> _hiTempController = StreamController<int>.broadcast();
  StreamController<double> _deltaController = StreamController<double>.broadcast();
  StreamController<Object> _underHoodController = StreamController<Object>.broadcast();
  StreamController<double> _speedController = StreamController<double>.broadcast();
  List<BluetoothService> _services;
  BluetoothCharacteristic c;
  BluetoothDevice _connectedDevice;
  StreamSubscription<Object> reader;
  Set<String> tcList = new Set<String>();
  String apwSet = "";
  int obd2Length = 0;
  bool connected = false;
  //Nav navInstance;


  @override
  void initState() {
    // Calling superclass initState
    super.initState();
    //navInstance = new Nav();
    // Will be set to true on reconnect or 1st connect
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
      widget.flutterBlue.stopScan();
      // Conduct Scan
      widget.flutterBlue.startScan();
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
              connected = true;
            });
          }
        }
      });
    }
  }
routeSpeed(double val) {
    _speedController.add(val);
}
  void changeToTCPage() {
    if (this.mounted) {
      setState(() {
        HomePage.leftIndex = 2;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff181818),
      //TODO: Leave BT Settings and possible side menu
        body: Column(children: [
          Container(height: 150,),
          Row(
            children: [
              VerticalDivider(width: 50),
              Column (
                children: [
              Container(
                  height: 450,
                  width: 450,
                  child:
                  IndexedStack(
                    index: HomePage.leftIndex,
                    children: [Container(margin: EdgeInsets.symmetric(
                        vertical: 0, horizontal: 0),
                        child: Speedometer()),
                      Center(child: AddBMSData(socStream: _socController.stream,
                        lowStream: _lowController.stream,
                        hiStream: _hiController.stream,
                        packVoltStream: _packVoltSumController.stream,
                        currentDrawStream: _currentDrawController.stream,
                        deltaStream: _deltaController.stream,
                        hiTempStream: _hiTempController.stream,
                        speedStream: _speedController.stream,
                        underHoodStream: _underHoodController.stream,
                        ctcStream: _ctcController.stream,
                        ptcStream: _ptcController.stream,
                        apwiStream: _apwController.stream,)),
                      Center(child: TroubleCodes(ctcStream: _ctcController.stream, ptcStream: _ptcController.stream))

                    ],
                  )),
                  Row(
                      children: [
                        VerticalDivider(width: 15),
                        if (HomePage.leftIndex > 0) ElevatedButton(onPressed: () {
                          setState(() {
                            --HomePage.leftIndex;
                          });
                        },
                          child: Icon(
                            Icons.arrow_back_ios_new, color: Color(
                              0xffedd711),),
                          style: ElevatedButton.styleFrom(primary: Color(
                              0xff03050a).withOpacity(0),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(18),),),
                        if (HomePage.leftIndex == 0) VerticalDivider(width: 65),
                        VerticalDivider(width: 150),
                        if (HomePage.leftIndex < 2 ) ElevatedButton(onPressed: () {
                          setState(() {
                            ++HomePage.leftIndex;
                          });
                        },
                          child: Icon(Icons.arrow_forward_ios, color: Color(
                              0xffedd711),),
                          style: ElevatedButton.styleFrom(primary: Color(
                              0xff03050a).withOpacity(0),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(18),),),
                        if (HomePage.leftIndex == 2) VerticalDivider(width: 65),
                      ]
                  ),
                ],
              ),
              VerticalDivider(width: 50),
              Column( children: [
                Container( height: 450, child:
                CenterIndicators(socStream: _socController.stream,
                                 hiStream: _hiController.stream,
                                 lowStream: _lowController.stream,
                                 packVoltStream: _packVoltSumController.stream,
                                 hiTempStream: _hiTempController.stream,
                                 currentDrawStream: _currentDrawController.stream,),), Container(
                height: 100,
                width: 146,
                child:
                Warnings(ctcStream: _ctcController.stream, ptcStream: _ptcController.stream, apwiStream: _apwController.stream, callback: () => setState(() => HomePage.leftIndex = 2),),)
              ]),
              VerticalDivider(width: 50),
              Column(
                children: [
                  Container(height: 10,),
                  Container(
                      height: 450,
                      width: 450,
                      child:
                      IndexedStack(
                        index: HomePage.rightIndex,
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
                                  height: 500, width: 500, child: Container()/*navInstance*/))),
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
                        if (HomePage.rightIndex > 0) ElevatedButton(onPressed: () {
                          setState(() {
                            --HomePage.rightIndex;
                          });
                        },
                          child: Icon(
                            Icons.arrow_back_ios_new, color: Color(
                              0xffedd711),),
                          style: ElevatedButton.styleFrom(primary: Color(
                              0xff03050a).withOpacity(0),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(18),),),
                        if (HomePage.rightIndex == 0) VerticalDivider(width: 65),
                        if (HomePage.rightIndex != 1)
                          VerticalDivider(width: 150),
                        if (HomePage.rightIndex == 1)
                          VerticalDivider(width: 44,),
                        if (HomePage.rightIndex == 1)
                           ElevatedButton(onPressed: () {
                            setState(() {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => NavDirections()/*FullScreenNav()*/),);
                            });
                          },
                            child: Icon(Icons.fullscreen, color: Color(
                                0xffedd711), size: 40,),
                            style: ElevatedButton.styleFrom(primary: Color(
                                0xff03050a).withOpacity(0),
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(11),),),
                        if (HomePage.rightIndex == 1)
                          VerticalDivider(width: 44),
                        if (HomePage.rightIndex < 2 ) ElevatedButton(onPressed: () {
                          setState(() {
                            ++HomePage.rightIndex;
                          });
                        },
                          child: Icon(Icons.arrow_forward_ios, color: Color(
                              0xffedd711),),
                          style: ElevatedButton.styleFrom(primary: Color(
                              0xff03050a).withOpacity(0),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(18),),),
                        if (HomePage.rightIndex == 2) VerticalDivider(width: 65),
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
  Future<Null> obd2Req(val) async{
    // Writing Request to Arduino:
    int retry = 0;
    do {
      try {
        return await c.write(utf8.encode(val));
      } catch (e) {
        await Future.delayed(Duration(milliseconds: 100));
        ++retry;
      }
    } while(retry < 3);
  }

  void notify() async {
    for (BluetoothService service in _services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        //print(characteristic.uuid.toString());
        if (characteristic.uuid.toString() ==
            "0000ffe1-0000-1000-8000-00805f9b34fb") {
          c = characteristic;
          int retry = 0;
          do {
            try {
              await c.setNotifyValue(true);
              retry = 3;
            } on PlatformException {
              await Future.delayed(Duration(milliseconds: 100));
              ++retry;
            }
          } while(retry < 3);

          reader = c.value.listen((event) {});

          reader.onData((data) async{
            //print(utf8.decode(data));
            // This is where we receive our CAN Messages
            String message = utf8.decode(data);
            if (message.isNotEmpty) {
              if (message[0] == 'C' || message[0] == 'P' ) {

                Iterable<Characters> lenHelp = Characters(message).split(Characters('_'));
                int newObd2Length = int.parse(lenHelp.elementAt(1).toString());
                if (newObd2Length != obd2Length && obd2Length != 0){
                  // Clear the Set and Broadcast it to the TC Widget
                  tcList.clear();
                  _ctcController.add(tcList);
                  _ptcController.add(tcList);
                }
                // Initialize obd2Length with new unique length
                obd2Length = newObd2Length;
                if (obd2Length != 0) {
                  Iterable<Characters> faults = lenHelp.elementAt(2).split(Characters('!'));
                  faults.forEach((element) {
                    String fault = "P" + element.toString();
                    for (int i = 0; i < 50; i++) {
                      print(fault);
                    }
                    if (fault.length == 5)
                      tcList.add(fault);
                  });
                  message[0] == 'C' ? _ctcController.add(tcList) : _ptcController.add(tcList);
                } else
                {
                  // Clear the Set and Broadcast it to the TC Widget
                  tcList.clear();
                  _ctcController.add(tcList);
                  _ptcController.add(tcList);
                }
              }

              if (message[0] == 'r') {
                print(message);
                  UnderHood uh = new UnderHood();
                  Iterable<Characters> components = Characters(message).skip(message.indexOf('!') + 1).split(Characters('!'));
                  for (int i = 0; i < components.length; i++) {
                    if (i == 0) {
                      print("cell id = " + int.parse(components.elementAt(i).toString(), radix: 16).toString());
                      uh.cellId = int.parse(components.elementAt(i).toString().toLowerCase(), radix: 16);
                    } else if (i == 1){
                      uh.instV = int.parse(components.elementAt(i).toString().toLowerCase(), radix: 16)/10000.toDouble();
                    } else if (i == 2) {
                      uh.isShunting = components.elementAt(i).toString() == '1';
                    } else if (i == 3) {
                      uh.intRes = int.parse(components.elementAt(i).toString().toLowerCase(), radix: 16)/100.toDouble();
                    } else if (i == 4) {
                      String hex = components.elementAt(i).toString().toLowerCase();
                      uh.openV = int.parse("0x$hex")/10000.toDouble();
                    }
                  }
                  _underHoodController.add(uh);
              }


              else if (message[0] == 'V') {
                var auxPackVoltage = num.tryParse(message.substring(1, 4)).toDouble();
                if (auxPackVoltage < 2) {
                  //apwSet.add(auxPackVoltage.toString());
                  _apwController.add(auxPackVoltage.toString());
                } else {
                  //apwSet.clear();
                  _apwController.add("");
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
                    10);
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

              // Poll for Current Trouble Codes
              await obd2Req("ctc#");

              // Poll for Pending Trouble Codes
              await obd2Req("ptc#");
            }
          });
        }
      }
    }
  }
}