import 'dart:convert';
import 'dart:typed_data';

import 'package:bt01_serial_test/widgets/customButtonWidget.dart';
import 'package:bt01_serial_test/widgets/gameButton.dart';
//import 'package:bt01_serial_test/widgets/speedometer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models.dart';
import '../utils.dart';
import 'customButtonPage.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

SfRadialGauge speedo;
double _currentValue = 50.0;

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {


  Widget speedometer()
  {
    return SfRadialGauge(enableLoadingAnimation: true, animationDuration: 4500,
        title: GaugeTitle(
            text: 'Speed',
            textStyle:
            const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xff6df1d8))),
        axes: <RadialAxis>[
          RadialAxis(minimum: 0, maximum: 100, ranges: <GaugeRange>[
            GaugeRange(
                startValue: 0,
                endValue: 33,
                color: Color(0xffffd319),
                startWidth: 10,
                endWidth: 10),
            GaugeRange(
                startValue: 33,
                endValue: 66,
                color: Color(0xffff901f),
                startWidth: 10,
                endWidth: 10),
            GaugeRange(
                startValue: 66,
                endValue: 100,
                color: Color(0xffff2975),
                startWidth: 10,
                endWidth: 10)
          ], pointers: <GaugePointer>[
            NeedlePointer(value: _currentValue,
                onValueChanged: (double newValue) {
                setState(() {
                    _currentValue = newValue;
                  });
                },
                needleColor: Color(0xfff222ff),
                knobStyle: KnobStyle(color: Color(0xff8c1eff), borderColor: Color(0xff6df1d8), borderWidth: 0.01),
                enableAnimation: true)

          ], annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Container(
                    child: const Text('50',
                        style: TextStyle(color: Color(0xff6df1d8),
                            fontSize: 25, fontWeight: FontWeight.bold))),
                angle: 90,
                positionFactor: 0.5)
          ])
        ]);
    /**
        Widget gamePad(dynamic onTap) {
        return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
        Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
        gameButton("^", (TapDownDetails details) {
        onTap(0);
        })
        ],
        ),
        Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
        gameButton("<", (TapDownDetails details) {
        onTap(2);
        }),
        Container(width: 30),
        gameButton("O", (TapDownDetails details) {
        onTap(4);
        }),
        Container(width: 30),
        gameButton(">", (TapDownDetails details) {
        onTap(3);
        }),
        ],
        ),
        Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
        gameButton("⌄", (TapDownDetails details) {
        onTap(1);
        })
        ],
        ),
        ],
        );**/
  }

  List<DeviceWithAvailability> devices = <DeviceWithAvailability>[];
  BluetoothDevice _selectedDevice;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothConnection connection;
  List<Message> messages = <Message>[];
  SharedPreferences _pref;
  List<CustomButton> customButtons = [];
  int speed = 0;
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
      getStoredButtons();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController?.dispose();
    _tabController?.dispose();
    connection?.dispose();
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
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
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            // List of paired devices
            speedo = speedometer(),
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
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    speed = int.parse(messages[i].text);

                    return Text(messages[i].text);
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
                        ListView.builder(
                          itemCount: customButtons.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    gameButton("Edit", (TapDownDetails _) {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  CustomButtonPage(_pref)))
                                          .then((_) {
                                        getStoredButtons();
                                      });
                                    })
                                  ]);
                            }
                            CustomButton b = customButtons[index - 1];
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: customButtonWidget(b, (String val) async {
                                if (connection?.isConnected == true) {
                                  connection.output
                                      .add(utf8.encode("$val\r\n"));
                                  await connection.output.allSent;
                                }
                              }),
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
        tabs: [Tab(text: "Garb"), Tab(text: "Speedo"), Tab(text: "Custom")],
      ),
    );
  }

  void _getDevices() {
    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => DeviceWithAvailability(
                device,
                DeviceAvailability.maybe,
              )..isPaired = true,
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
              : _messageBuffer + dataString)
          .trim();
    }
    speedo.axes[0].pointers[0].onValueChanged((speed.toDouble()));
  }

  void getStoredButtons() {
    customButtons = getCustomButtons(_pref);
    if (customButtons.length == 0) {
      customButtons.add(CustomButton(0, "LED 1", "0", "1"));
      customButtons.add(CustomButton(1, "Event 1", "1"));
      setCustomButtons(_pref, customButtons);
    }
  }
}
