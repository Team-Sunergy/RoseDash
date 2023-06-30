import 'dart:async';

import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:geolocator/geolocator.dart' as gl;


import 'dart:convert';
import 'dart:io';
import 'package:characters/characters.dart';
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


//PSUEDO CODE

/// Creates a HomePage Class, which inherits Stateful Widget
///
/// Stateful means its possible to change fluently,
/// and a Widget is sort of like a grid/icon on the screen
/// which we can set (sorta)
class HomePage extends StatefulWidget {
  //CREATES CLASS HOMEPAGE

  ///For left Index in IndexedStack
  static int leftIndex = 0;
  static int rightIndex = 0;

  @override
  State<StatefulWidget> createState() => HomePageState();

}

/// This is what we are using to override createState()
///
/// :DDDD
class HomePageState extends State<HomePage> {
  /// Port, which handles the connection with the USB serial port
  late UsbPort _port; //TODO: FIX late

  /// This is the current status of the app, and whether a USB is
  /// connected or not connected (or disconnected)
  String _status = "Idle";

  /// Device State, a boolean for checking if device is connected
  bool _deviceState = false;

  /// This is an Array of Linked List ports.
  ///
  /// In terms of Bluetooth, I think this may be like services (maybe)
  List<UsbPort> _ports = [];

  /// A linked list of empty array for serial data, which is the data pulled
  /// from the USB
  List _serialData = [];

  /// A subscription provides events to the listener, and other functionality.
  StreamSubscription<String>? _subscription;

  StreamSubscription<Uint8List>? _reader;

  /// Transaction makes using the USBPort Class MUCH easier
  Transaction<String>? _transaction;

  /// The device that the USB has connected to.
  UsbDevice? _device;

  ///UNSURE //TODO: THIS
  Set<String> tcList = new Set<String>(); //collection of objects

  //UNSURE //TODO: THIS
  int obd2Length = 0;
  late Nav navInstance;

  // THE CODE BELOW IS STUFF IDK
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
  StreamController<bool> _connectedController = //NO
  StreamController<bool>.broadcast();
  StreamController<int> _mphController = StreamController<int>.broadcast();

  //PSUEDO CODE

  //FIRST WE NEED TO CONNECT TO A DEVICE
  /*TODO: Create method which connects to a specified device
          This needs to seet Subscription (which needs to be a reference
          from the USBPort (which we will use transaction for), and it needs to
          set transaction. Setting _port DTR and RTS to true, and port
          parameters is also needed. And serialData.



   */

  ///this code connects to the device,
  ///
  ///it returns a future
  Future _connectTo(device) async {

    _serialData.clear(); //clears all objects in _serialData

    //checks if device is present
    if (device == null) { //if there is no device in param
      _device = null; //set _device to null
      print('No USB devices found/Disconnected');
      return;
    }

    //clears transaction
    if (_transaction != null)
      _transaction!.dispose(); //releases underlying stream
    _transaction = null; //sets transaction to null

    //clears any ports
    if (_port != null) {
      _port!.close(); //closes any ports still open
      _port = null as UsbPort; //TODO FIND SOLUTION TO ERROR WHEN TAKE AWAY AS USBPORT
    }

    //we await for device.create
    _port = await device.create();
    if (await (_port!.open()) != true) {
      setState(() { //we make sure the port is open
        _status = "Failed to open port";
      }); //if its not, we return boolean
      return;
    }

    _device = device; //we assign the device field to the device itself
    await _port!.setDTR(true); //sets DTR port to true
    await _port!.setRTS(true); //sets RTS part to true
    await _port!.setPortParameters(9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    // we await for port to set the port parameters till we continue

    _transaction = Transaction.stringTerminated(_port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));
    // sets local transaction value to the value specified from the port input stream, from the list 13, 10,
    // we are defining port!.inputStream as Stream<Uint8List>
    _subscription = _transaction!.stream.listen((String line) {  //subscription is listening for transactions across the stream
      setState(() { //we set state for serial data
        _serialData.add(Text(line)); //takes a string converts it to a text , adds that text widget to the serial data
        if (_serialData.length > 20) { //MAYBE NOT NEEDED
          _serialData.removeAt(0); //we are removing the oldest node widget
        }
      });
    });

    //if we have gotten thus far, we are succesfully connected
    setState(() {
      _status = "Connected";
      _deviceState = true; //status is connected
    });
    return true;
  }

  /// grabs ports from the list of USB devices
  ///
  ///WE USE THIS TO CONNECT TO THE DEVICE
  void _getPorts() async {
    _ports = []; //ports is an empty array
    List<UsbDevice> devices = await UsbSerial.listDevices(); //list of devices
    if (!devices.contains(_device)) {       //checks if _device is on devices Icons.list
        _connectTo(_device);
    }

    print(devices); //just prints devices to console
  }

  ///set speed method for mph controller
  void setSpeed(int speed) {
    _mphController.add(speed);
  }


  ///Converts hex to Int
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
            res += 10 * pow(16, i) as int;
            break;
          case 'b':
            res += 11 * pow(16, i) as int;
            break;
          case 'c':
            res += 12 * pow(16, i) as int;
            break;
          case 'd':
            res += 13 * pow(16, i) as int;
            break;
          case 'e':
            res += 14 * pow(16, i) as int;
            break;
          case 'f':
            res += 15 * pow(16, i) as int;
            break;
          case '1':
            res += pow(16, i) as int;
            break;
          case '2':
            res += 2 * pow(16, i) as int;
            break;
          case '3':
            res += 3 * pow(16, i) as int;
            break;
          case '4':
            res += 4 * pow(16, i) as int;
            break;
          case '5':
            res += 5 * pow(16, i) as int;
            break;
          case '6':
            res += 6 * pow(16, i) as int;
            break;
          case '7':
            res += 7 * pow(16, i) as int;
            break;
          case '8':
            res += 8 * pow(16, i) as int;
            break;
          case '9':
            res += 9 * pow(16, i) as int;
            break;
        }
      }
    }
    return res;
  }


  @override
  /// normal initState, but with new initiated fields
  /// for our HomePageState Class
  void initState() {
    // Calling superclass initState
    super.initState();

    navInstance = new Nav(callback: (event) => {routeLocationToDB(event)},); //GPS

    UsbSerial.usbEventStream!.listen((UsbEvent event) { //listens for usb event

      _getPorts(); //and also gets ports
    });

    //BEGAN CAN COMM
    notify();
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



  //we want to cycle through each of the usbs (there should only
  //be one) and check


//UNSURE
  Future<void> obd2Req(val) async {
    // Writing Request to Arduino:
    int retry = 0;

    //making the bytes that will be written
    List<int> bytes = utf8.encode(val);
    do {
      try {
        return await _port.write(bytes as Uint8List);
      } catch (e) {
        await Future.delayed(Duration(milliseconds: 100));
        ++retry;
      }
    } while (retry < 3);
  }

  int speedRead(String speed) {
    speed = speed.substring(0, speed.indexOf("\r"));
    int res = 0;
    speed = speed.split('').reversed.join();
    for (int i = 0; i < speed.length; i++) {
      // Dart Sucks
      switch (speed[i]) {
        case '1':
          res += pow(10, i) as int;
          break;
        case '2':
          res += 2 * pow(10, i) as int;
          break;
        case '3':
          res += 3 * pow(10, i) as int;
          break;
        case '4':
          res += 4 * pow(10, i) as int;
          break;
        case '5':
          res += 5 * pow(10, i) as int;
          break;
        case '6':
          res += 6 * pow(10, i) as int;
          break;
        case '7':
          res += 7 * pow(10, i) as int;
          break;
        case '8':
          res += 8 * pow(10, i) as int;
          break;
        case '9':
          res += 9 * pow(10, i) as int;
          break;
      }
    }
    return res;
  }



  //TODO: Make a notify() command? IDK WHAT THIS DOES??
  // BLAME THE NO EXPLANATION CODE ON SAM AND LOGAN LOVE THOSE GUYS THOUGH
  void notify() async {
    // for (UsbPort Port in _ports) { //FOR USB PORTS in THE ARRAY OF PORTS
    //   if (Port.uuid.toString() ==
    //   "0000ffe1-0000-1000-8000-00805f9b34fb")  {
    _reader = _port?.inputStream?.listen((event) {});

    _reader?.onData((data) async{
      print(utf8.decode(data));
      // This is where we receive our CAN Messages
      String message = ascii.decode(data);
      if (message.isNotEmpty) {
        if (message[0] == 'k') {
          //print(message);
          double current;
          if (message[1] == 'N') {
            current = hexStringToInt(Characters(message).skip(2).toString()) * -.1;
          } else {
            print("current string:" + Characters(message).skip(2).toString());
            sleep(Duration(seconds:15));
            current = hexStringToInt(Characters(message).skip(2).toString()) * 0.1;
          }
          _currentDrawController.add(current);
        } else if (message[0] == 'r') {
          //print(message);
          UnderHood uh = new UnderHood();
          Iterable<Characters> components = Characters(message)
              .skip(message.indexOf('!') + 1)
              .split(Characters('!'));
          for (int i = 0; i < components.length; i++) {
            if (i == 0) {
              //print("cell id = " + int.parse('0x${components.elementAt(i).toString().toUpperCase()}').toString());
              uh.cellId =
                  hexStringToInt(components.elementAt(i).toString());
            } else if (i == 1) {
              uh.instV =
                  hexStringToInt(components.elementAt(i).toString()) /
                      10000;
            } else if (i == 2) {
              uh.isShunting = components.elementAt(i).toString() == '1';
            } else if (i == 3) {
              uh.intRes =
                  hexStringToInt(components.elementAt(i).toString()) /
                      100;
            } else if (i == 4) {
              uh.openV =
                  hexStringToInt(components.elementAt(i).toString()) /
                      10000;
            }
          }
          _underHoodController.add(uh);
        } else if (message[0] == 'C' || message[0] == 'P') {
          Iterable<Characters> lenHelp =
          Characters(message).split(Characters('_'));
          int newObd2Length = lenHelp.length >= 3
              ? int.parse(lenHelp.elementAt(1).toString())
              : 0;
          if (newObd2Length != obd2Length && obd2Length != 0) {
            // Clear the Set and Broadcast it to the TC Widget
            tcList.clear();
            _ctcController.add(tcList);
            _ptcController.add(tcList);
          }
          // Initialize obd2Length with new unique length
          obd2Length = newObd2Length;
          if (obd2Length != 0) {
            if (lenHelp.length >= 3) {
              Iterable<Characters> faults =
              lenHelp.elementAt(2).split(Characters('!'));
              faults.forEach((element) {
                String fault = "P" + element.toString();
                for (int i = 0; i < 50; i++) {
                  //print(fault);
                }
                if (fault.length == 5) tcList.add(fault);
              });
              message[0] == 'C'
                  ? _ctcController.add(tcList)
                  : _ptcController.add(tcList);
            }
          } else {
            // Clear the Set and Broadcast it to the TC Widget
            tcList.clear();
            _ctcController.add(tcList);
            _ptcController.add(tcList);
          }
        } else if (message[0] == 's') {
          //message =
          //int speed = speedRead(Characters(message.trim()).replaceAll(Characters("ss"), Characters.empty).toString());
          int speed = speedRead(Characters(message)
              .split(Characters('\r'))
              .elementAt(0)
              .skip(2)
              .toString());
          _mphController.add(speed);
        } else if (message[0] == 'V') {
          var auxPackVoltage =
          num.parse(message.substring(1, 4)).toDouble();
          if (auxPackVoltage < 2) {
            //apwSet.add(auxPackVoltage.toString());
            _apwController.add(auxPackVoltage.toString());
          } else {
            //apwSet.clear();
            _apwController.add("");
          }
        } else if (message[0] == 'G') {
          for(int i = 0; i < 50; i++) {
            print(message);
          }
          for(int i = 0; i < 100; i++) {
            print("soc is " + message.substring(1, 3));
          }
          _socController.add(hexStringToInt(message.substring(1, 3)) / 2);
          _hiController
              .add(hexStringToInt(message.substring(4, 8)) / 10000);
          _lowController
              .add(hexStringToInt(message.substring(9, 13)) / 10000);
          _packVoltSumController
              .add(hexStringToInt(message.substring(14, 18)) / 10);
          _hiTempController
              .add(hexStringToInt(message.substring(19, 21)));
          // Arithmetic is performed in VoltMeter Widget
          _deltaController.add(0);
        }

        await obd2Req("vtr#");

        // Poll for Absolute Pack Current Draw
        await obd2Req("upc#");

        // Poll for Current Trouble Codes
        await obd2Req("ctc#");

        // Poll for Pending Trouble Codes
        await obd2Req("ptc#");


        message = "";
      }
    });

      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(children: [
          Container(
              height: 150,
              child: Row(children: [
                //LeftTurnSignal(),
                Container(width: 1205, child: BluetoothIcon(connectStream: _connectedController.stream,))]
              )),
          Row(
            children: [
              VerticalDivider(width: 50),
              Column(
                children: [
                  //Container(child: TurnSignal()),
                  Container(
                    height: 450,
                    width: 450,
                    child: IndexedStack(
                      index: HomePage.leftIndex,
                      children: [
                        Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 0),
                            child: Speedometer(
                              timeOn: true,
                              mphStream: _mphController.stream,
                              callback: (speed) => {setSpeed(speed.toInt())},
                            )),
                        Center(
                            child: AddBMSData(
                                socStream: _socController.stream,
                                lowStream: _lowController.stream,
                                hiStream: _hiController.stream,
                                packVoltStream: _packVoltSumController.stream,
                                currentDrawStream:
                                _currentDrawController.stream,
                                deltaStream: _deltaController.stream,
                                hiTempStream: _hiTempController.stream,
                                speedStream: _mphController.stream,
                                underHoodStream: _underHoodController.stream,
                                ctcStream: _ctcController.stream,
                                ptcStream: _ptcController.stream,
                                apwiStream: _apwController.stream,
                                latStream: _latController.stream,
                                longStream: _longController.stream,
                                altStream: _altController.stream,
                                connectStream: _connectedController.stream)),
                        Center(
                            child: TroubleCodes(
                                ctcStream: _ctcController.stream,
                                ptcStream: _ptcController.stream))
                      ],
                    ),
                  ),
                  Row(children: [
                    VerticalDivider(width: 15),
                    if (HomePage.leftIndex > 0)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            --HomePage.leftIndex;
                          });
                        },
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xffedd711),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xffffffff).withOpacity(0),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(18),
                        ),
                      ),
                    if (HomePage.leftIndex == 0) VerticalDivider(width: 65),
                    VerticalDivider(width: 150),
                    if (HomePage.leftIndex < 2)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            ++HomePage.leftIndex;
                          });
                        },
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xffedd711),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xff03050a).withOpacity(0),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(18),
                        ),
                      ),
                    if (HomePage.leftIndex == 2) VerticalDivider(width: 65),
                  ]),
                ],
              ),
              VerticalDivider(width: 50),
              Column(children: [
                Container(
                  height: 450,
                  child: CenterIndicators(
                    socStream: _socController.stream,
                    hiStream: _hiController.stream,
                    lowStream: _lowController.stream,
                    packVoltStream: _packVoltSumController.stream,
                    hiTempStream: _hiTempController.stream,
                    currentDrawStream: _currentDrawController.stream,
                  ),
                ),
                Container(
                  height: 100,
                  width: 146,
                  child: Warnings(
                    ctcStream: _ctcController.stream,
                    ptcStream: _ptcController.stream,
                    apwiStream: _apwController.stream,
                    callback: () => setState(() => HomePage.leftIndex = 2),
                  ),
                )
              ]),
              VerticalDivider(width: 50),
              Column(
                children: [
                  Container(
                    height: 10,
                  ),
                  Container(
                      height: 450,
                      width: 450,
                      child: IndexedStack(
                        index: HomePage.rightIndex,
                        children: [
                          Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 30),
                              child: VoltMeter(
                                socStream: _socController.stream,
                                lowStream: _lowController.stream,
                                hiStream: _hiController.stream,
                                packVoltStream: _packVoltSumController.stream,
                                deltaStream: _deltaController.stream,
                                hiTempStream: _hiTempController.stream,
                              )),
                          Center(
                              child: ClipRRect(
                                  borderRadius: BorderRadius.horizontal(
                                      left: Radius.elliptical(150, 150),
                                      right: Radius.elliptical(150, 150)),
                                  child: Container(
                                      height: 500,
                                      width: 500,
                                      child: navInstance))),
                          Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 0),
                              child: Speedometer(
                                timeOn: true,
                                mphStream: _mphController.stream,
                                callback: (speed) => {setSpeed(speed.toInt())},
                              )),
                          /*Center(
                              child: SOCGraph(
                            socStream: _socController.stream,
                            packVoltStream: _packVoltSumController.stream,
                          )),*/
                        ],
                      )),
                  Container(
                    height: 10,
                  ),
                  Row(children: [
                    VerticalDivider(width: 15),
                    if (HomePage.rightIndex > 0)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            --HomePage.rightIndex;
                          });
                        },
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xffedd711),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xffffffff).withOpacity(0),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(18),
                        ),
                      ),
                    if (HomePage.rightIndex == 0) VerticalDivider(width: 65),
                    if (HomePage.rightIndex != 1) VerticalDivider(width: 150),
                    if (HomePage.rightIndex == 1)
                      VerticalDivider(
                        width: 44,
                      ),
                    if (HomePage.rightIndex == 1)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FullScreenNav(nav: navInstance)),
                            ); //NavDirections()/*FullScreenNav()*/),);
                          });
                        },
                        child: Icon(
                          Icons.fullscreen,
                          color: Color(0xffedd711),
                          size: 40,
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xffffffff).withOpacity(0),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(11),
                        ),
                      ),
                    if (HomePage.rightIndex == 1) VerticalDivider(width: 44),
                    if (HomePage.rightIndex < 2)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            ++HomePage.rightIndex;
                          });
                        },
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xffedd711),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xffffffff).withOpacity(0),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(18),
                        ),
                      ),
                    if (HomePage.rightIndex == 2) VerticalDivider(width: 65),
                  ]),
                  Container(
                    height: 10,
                  ),
                ],
              )
            ],
          ),
        ]));
  }
    }

  //TODO: Using initState, connect using a the previous method.















class UnderHood {
  int? cellId;
  double? instV;
  bool? isShunting;
  double? intRes;
  double? openV;
}