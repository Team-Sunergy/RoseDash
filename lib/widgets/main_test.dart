import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

void main() => runApp(MyApp()); //designating main to run runAPp

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState(); //this overrides createState MyAppState() and sets it to _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UsbPort? _port; //USBPort? will accept null, _port
  String _status = "Idle"; //Status is automatically Idle
  List<Widget> _ports = []; //LinkedList of Widgets
  List<Widget> _serialData = []; //LinkedList of Widgets for serialData

  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbDevice? _device;

  TextEditingController _textController = TextEditingController(); //this is a controller for an editable text field

  Future<bool> _connectTo(device) async { //A future is a ??? which
    //runs after a designated amount of time or after something has
    //been done. So this function will only complete after it has been
    //designated such
    _serialData.clear(); //this clears serialData

    if (_subscription != null) { //this checks if subscription is null
      _subscription!.cancel(); //if it isnt, it cancel and sets subscription
      //to null
      _subscription = null;
    }

    if (_transaction != null) { //same thing as above
      _transaction!.dispose(); //releases underlying stream if not null
      _transaction = null; //sets to null
    }

    if (_port != null) { //checks if null
      _port!.close(); //closes port if not null
      _port = null; //sets port to null
    }

    if (device == null) { //if the device is null
      _device = null; //set _device to null
      setState(() {
        _status = "Disconnected :("; //and mark status using setState() to
      }); //disconnect
      return true; //Then, return
    }

    _port = await device.create(); //im assuming 'await' waits for device.create()
    if (await (_port!.open()) != true) { //if my _port does not equal null when open, and it does not return false
      setState(() {
        _status = "Failed to open port"; //setting status if port doesnt open
      });
      return false; //return a false boolean for future
    }
    _device = device; //we are assinging field for device to local device

    await _port!.setDTR(true); //sets DTR port to true
    await _port!.setRTS(true); //sets RTS part to true
    await _port!.setPortParameters(9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    // we await for port to set the port parameters till we continue

    _transaction = Transaction.stringTerminated(_port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));
    // sets local transaction value to the value specified from the port input stream, from the list 13, 10,
    // we are defining port!.inputStream as Stream<Uint8List>

    _subscription = _transaction!.stream.listen((String line) {  //subscription is listening for transactions across the stream
      setState(() { //we set state for serial data
        _serialData.add(Text(line)); //takes a string converts it to a text widget, adds that text widget to the serial data
        if (_serialData.length > 20) { //MAYBE NOT NEEDED
          _serialData.removeAt(0); //we are removing the oldest node widget
        }
      });
    });

    setState(() { //If we have gotten this far, status connected!
      _status = "Connected";
    });
    return true;
  }

  void _getPorts() async {
    _ports = []; //ports is an empty array
    List<UsbDevice> devices = await UsbSerial.listDevices(); //devices is set to whatever devices from current USB Devie
    if (!devices.contains(_device)) { //if this device is not in the devices list
      _connectTo(_device); //then connect to the device
    }
    print(devices); //print devices (debuging/displaying services)

    devices.forEach((device) { //for each device object in the list of devices do the following
      _ports.add(ListTile( //for each device port,
          leading: Icon(Icons.usb), //display icon
          title: Text(device.productName ?? "Unknown Product"), //display title of devie
          subtitle: Text(device.manufacturerName ?? "Unknown Manufacturer"), //?? if device is null, print the second thing NULL COLES
          trailing: ElevatedButton(
            child: Text(_device == device ? "Disconnect" : "Connect"),
            onPressed: () { //adds a button to connect to the device
              _connectTo(_device == device ? null : device).then((res) {
                _getPorts();
              });
            },
          )));
    });

    setState(() {
      print(_ports); //we print the ports
    });
  }

  @override
  void initState() {
    super.initState();

    UsbSerial.usbEventStream!.listen((UsbEvent event) { //listens for usb event
      _getPorts(); //and also gets ports
    });

    _getPorts(); //unsure why this happens
  }

  @override
  void dispose() { //gets rid of the object so we dont have memory leaks, removes ram
    super.dispose();
    _connectTo(null); //overrides and connects to null, which resets connection
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp( //just widget type :)
        home: Scaffold( //visual scaffold
          appBar: AppBar( //the blue bar at the top
            title: const Text('USB Serial Plugin example app'),
          ),
          body: Center(
              child: Column(children: <Widget>[
                Text(_ports.length > 0 ? "Available Serial Ports" : "No serial devices available", style: Theme.of(context).textTheme.headline6),
                ..._ports, //this is a conditional, yes blah blah
                Text('Status: $_status\n'), //pulls from status from earlier
                Text('info: ${_port.toString()}\n'),
                ListTile(
                  title: TextField(
                    controller: _textController, //
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Text To Send',
                    ),
                  ),
                  trailing: ElevatedButton(
                    child: Text("Send"),
                    onPressed: _port == null
                        ? null
                        : () async {
                      if (_port == null) {
                        return;
                      }
                      String data = _textController.text + "\r\n";
                      await _port!.write(Uint8List.fromList(data.codeUnits));
                      _textController.text = "";
                    },
                  ),
                ),
                Text("Result Data", style: Theme.of(context).textTheme.headline6),
                ..._serialData,
              ])),
        ));
  }
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
  StreamController<bool> _connectedController = //NO
  StreamController<bool>.broadcast();
  StreamController<int> _mphController = StreamController<int>.broadcast();
  List<BluetoothService> _services; //list of bluetooth services available
  BluetoothCharacteristic c; //TODO: LATER
  BluetoothDevice _connectedDevice; //USB DEVICE
  StreamSubscription<Object> reader; //THIS IS THE SAME AS USB SUBSCRIPTION
  Set<String> tcList = new Set<String>(); //collection of objects
  String apwSet = ""; //
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
              notify();
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
              Timer.periodic(Duration(seconds: 5), (Timer t1) => connected = _checkBTConnection());
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
    speed = speed.split('').reversed.join();
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

  Future<Null> obd2Req(val) async {
    // Writing Request to Arduino:
    int retry = 0;
    do {
      try {
        return await c.write(utf8.encode(val));
      } catch (e) {
        await Future.delayed(Duration(milliseconds: 100));
        ++retry;
      }
    } while (retry < 3);
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
          } while (retry < 3);

          reader = c.value.listen((event) {});

          reader.onData((data) async {
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
                num.parse(message.substring(1, 4))?.toDouble();
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
      }
    }
  }
}