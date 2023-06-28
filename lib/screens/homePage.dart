// @dart=2.9
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
//import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:characters/characters.dart';

// BLE Library
import 'package:flutter_blue/flutter_blue.dart';
import 'package:segment_display/segment_display.dart';

// Custom Widgets
import '../widgets/BluetoothIcon.dart';
import '../widgets/CenterIndicators.dart';
import '../widgets/LeftTurnSignal.dart';
import '../widgets/RightTurnSignal.dart';
import '../widgets/Warnings.dart';
import '../screens/FullScreenNav.dart';
import '../widgets/Nav.dart';
import '../widgets/Speedometer.dart';
import '../widgets/VoltMeter.dart';
import '../widgets/AddBMSData.dart';
import '../widgets/TroubleCodes.dart';
import '../widgets/SOCGraph.dart';
import '../widgets/BluetoothIcon.dart';

// Location Streaming
import 'package:geolocator/geolocator.dart' as gl;

bool connected = false;
//BluetoothDevice device;

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
  StreamController<Set<String>> _ctcController =
  StreamController<Set<String>>.broadcast();
  StreamController<Set<String>> _ptcController =
  StreamController<Set<String>>.broadcast();
  StreamController<String> _apwController =
  StreamController<String>.broadcast();
  StreamController<double> _socController =
  StreamController<double>.broadcast();
  StreamController<double> _lowController =
  StreamController<double>.broadcast();
  StreamController<double> _hiController = StreamController<double>.broadcast();
  StreamController<double> _packVoltSumController =
  StreamController<double>.broadcast();
  StreamController<double> _currentDrawController =
  StreamController<double>.broadcast();
  StreamController<int> _hiTempController = StreamController<int>.broadcast();
  StreamController<double> _deltaController =
  StreamController<double>.broadcast();
  StreamController<Object> _underHoodController =
  StreamController<Object>.broadcast();
  StreamController<double> _latController =
  StreamController<double>.broadcast();
  StreamController<double> _longController =
  StreamController<double>.broadcast();
  StreamController<double> _altController =
  StreamController<double>.broadcast();
  StreamController<bool> _connectedController =
  StreamController<bool>.broadcast();
  StreamController<int> _mphController = StreamController<int>.broadcast();
  List<BluetoothService> _services;
  BluetoothCharacteristic c;
  BluetoothDevice _connectedDevice;
  StreamSubscription<Object> reader;
  Set<String> tcList = new Set<String>();
  String apwSet = "";
  int obd2Length = 0;
  Nav navInstance;
  BluetoothDeviceState deviceState;

  @override
  void initState() {
    // Calling superclass initState
    super.initState();
    navInstance = new Nav(callback: (event) => {routeLocationToDB(event)},);
    // Will be set to true on reconnect or 1st connect
    // Reconnect to previously found device
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) async {
      connected = true;
      for (BluetoothDevice device in devices) {
        if (device.name.toString() == "otter") {
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
            // notify();
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
        //BluetoothDevice device;
        for (ScanResult r in result) {
          // Auto-Connect to HM-19
          if (r.device.name.toString() == "otter") {
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
              //notify();
              // OBD2 Request Call
              //obd2Req("nice\n");
            }
            if (this.mounted)
              setState(() {
                _connectedDevice = r.device;
                connected = true;
              });
            _connectedDevice.state.listen((s) {
              if (this.mounted) {
                deviceState = s;
              }
              Timer.periodic(Duration(seconds: 5), (Timer t1) =>
              connected = _checkBTConnection());
            });
          }
        }
      });
    }
  }

  bool _checkBTConnection() {
    bool connect = deviceState == BluetoothDeviceState.connected;
    //print("\n\n\n BT Device State is: " + connect.toString() + "\n\n\n\n\n\n");
    _connectedController.add(connect);
    return connect;
  }

  void setSpeed(int speed) {
    _mphController.add(speed);
  }

  /*Align _btIcon()
  {
    if (connected)
    {
      return Align(alignment: Alignment.topLeft,
          child: (Container(child: Icon(
              IconData(0xf5c1, fontFamily: 'MaterialIcons'), size: 75,
              color: Color(0xffffffff))))
      );
    }
    else
    {
      return Align();
    }
  }*/

  int hexStringToInt(String hex) {
    int res = 0;
    if (hex.length >= 4 || hex.length == 2) {
      hex = Characters(hex).take(4).toString();
      hex = hex
          .split('')
          .reversed
          .join();
      hex = hex.toLowerCase();
      for (int i = 0; i < hex.length; i++) {
        // Dart Sucks
        switch (hex[i]) {
          case 'a':
            res += 10 * pow(16, i);
            break;
          case 'b':
            res += 11 * pow(16, i);
            break;
          case 'c':
            res += 12 * pow(16, i);
            break;
          case 'd':
            res += 13 * pow(16, i);
            break;
          case 'e':
            res += 14 * pow(16, i);
            break;
          case 'f':
            res += 15 * pow(16, i);
            break;
          case '1':
            res += pow(16, i);
            break;
          case '2':
            res += 2 * pow(16, i);
            break;
          case '3':
            res += 3 * pow(16, i);
            break;
          case '4':
            res += 4 * pow(16, i);
            break;
          case '5':
            res += 5 * pow(16, i);
            break;
          case '6':
            res += 6 * pow(16, i);
            break;
          case '7':
            res += 7 * pow(16, i);
            break;
          case '8':
            res += 8 * pow(16, i);
            break;
          case '9':
            res += 9 * pow(16, i);
            break;
        }
      }
    }
    return res;
  }

  int speedRead(String speed) {
    speed = speed.substring(0, speed.indexOf("\r"));
    int res = 0;
    speed = speed
        .split('')
        .reversed
        .join();
    for (int i = 0; i < speed.length; i++) {
      // Dart Sucks
      switch (speed[i]) {
        case '1':
          res += pow(10, i);
          break;
        case '2':
          res += 2 * pow(10, i);
          break;
        case '3':
          res += 3 * pow(10, i);
          break;
        case '4':
          res += 4 * pow(10, i);
          break;
        case '5':
          res += 5 * pow(10, i);
          break;
        case '6':
          res += 6 * pow(10, i);
          break;
        case '7':
          res += 7 * pow(10, i);
          break;
        case '8':
          res += 8 * pow(10, i);
          break;
        case '9':
          res += 9 * pow(10, i);
          break;
      }
    }
    return res;
  }

  routeLocationToDB(gl.Position position) {
    _latController.add(position.latitude);
    _longController.add(position.longitude);
    _altController.add(position.altitude);
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
    return Speedometer(
      timeOn: true,
      mphStream: _mphController.stream,
      callback: (speed) => {setSpeed(speed.toInt())},
    );
  }
}