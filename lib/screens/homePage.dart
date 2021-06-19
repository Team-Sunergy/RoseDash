import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<_DeviceWithAvailability> devices = <_DeviceWithAvailability>[];
  BluetoothDevice _selectedDevice;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothConnection connection;
  List<_Message> messages = <_Message>[];

  TextEditingController _controller = TextEditingController();
  TabController _tabController;

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
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    connection?.dispose();
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BT Serial"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _startDevice();
            },
          ),
          Icon(_btStateIcon(_bluetoothState)),
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
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            // List of paired devices
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
                    Text("Local Address: $_address"),
                    Text("Local Name: $_name"),
                    Expanded(
                      child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, i) {
                          return ListTile(
                            dense: true,
                            leading: Icon(Icons.devices),
                            title: Text(devices[i].device.name ?? "Unknown.."),
                            subtitle:
                                Text(devices[i].device.address.toString()),
                            trailing:
                                Text(devices[i].device.bondState.stringValue),
                            onTap: () {
                              if (devices[i].isPaired == true) {
                                setState(() {
                                  _selectedDevice = devices[i].device;
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
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
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
                            "Connected to ${_selectedDevice.name} ::: ${_selectedDevice.address}"),
                    Expanded(
                      child: TabBarView(controller: _tabController, children: [
                        GridView.builder(
                          padding: EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5),
                          itemCount: 10,
                          itemBuilder: (context, i) {
                            return Container(
                              margin: EdgeInsets.all(10),
                              color: Colors.teal,
                              child: IconButton(
                                icon: Text("$i", textScaleFactor: 2.0),
                                onPressed: () async {
                                  if (connection?.isConnected == true) {
                                    connection.output
                                        .add(utf8.encode("$i\r\n"));
                                    await connection.output.allSent;
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: [Tab(text: "NumPad")],
      ),
    );
  }

  IconData _btStateIcon(BluetoothState state) {
    if (state == BluetoothState.UNKNOWN) return Icons.do_disturb_alt_sharp;
    if (state == BluetoothState.ERROR) return Icons.error_outline_sharp;
    if (state == BluetoothState.STATE_BLE_ON) return Icons.ac_unit;
    if (state == BluetoothState.STATE_BLE_TURNING_OFF) return Icons.ac_unit;
    if (state == BluetoothState.STATE_BLE_TURNING_ON) return Icons.ac_unit;
    if (state == BluetoothState.STATE_OFF) return Icons.bluetooth_disabled;
    if (state == BluetoothState.STATE_ON) return Icons.bluetooth;
    if (state == BluetoothState.STATE_TURNING_ON) return Icons.ac_unit;
    if (state == BluetoothState.STATE_TURNING_OFF) return Icons.ac_unit;
    return Icons.details;
  }

  void _getDevices() {
    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
                device,
                _DeviceAvailability.maybe,
              )..isPaired = true,
            )
            .toList();
      });
    });
  }

  void _startDevice() {
    for (_DeviceWithAvailability d in devices) {
      if (d.isPaired == false) {
        devices.remove(d);
      }
    }
    FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        bool isPaired = false;
        for (_DeviceWithAvailability d in devices) {
          if (d.device == r.device) {
            d.availability = _DeviceAvailability.yes;
            d.rssi = r.rssi;
            isPaired = true;
          }
        }
        if (!isPaired) {
          _DeviceWithAvailability d = _DeviceWithAvailability(
              r.device, _DeviceAvailability.yes, r.rssi);
          d.isPaired = false;
          devices.add(d);
        }
      });
    }).onDone(() {
      for (_DeviceWithAvailability d in devices) {
        if (d.availability == _DeviceAvailability.maybe) {
          d.availability = _DeviceAvailability.no;
        }
      }
    });
  }

  void _startConnection() {
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
      print('Cannot connect, exception occured');
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
          _Message(
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
    } else {
      _messageBuffer = (backspacesCounter > 0
              ? _messageBuffer.substring(
                  0, _messageBuffer.length - backspacesCounter)
              : _messageBuffer + dataString)
          .trim();
    }
  }
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int rssi;
  bool isPaired;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _Message {
  final String name;
  final String text;

  _Message(this.name, this.text);
}

/*
TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                    ),
                    Center(
                      child: TextButton(
                        child: Text("Send"),
                        onPressed: () async {
                          if (_controller.text.isEmpty) return;
                          connection.output
                              .add(utf8.encode(_controller.text + "\r\n"));
                          await connection.output.allSent;
                          _controller.clear();
                        },
                      ),
                    )
*/
