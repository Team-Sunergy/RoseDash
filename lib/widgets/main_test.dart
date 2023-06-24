import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
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