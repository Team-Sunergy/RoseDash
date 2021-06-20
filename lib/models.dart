import 'dart:convert';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

enum DeviceAvailability {
  no,
  maybe,
  yes,
}

class DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice device;
  DeviceAvailability availability;
  int rssi;
  bool isPaired;

  DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class Message {
  final String name;
  final String text;

  Message(this.name, this.text);
}

class CustomButton {
  final int type; // 0: toggle, 1: tap
  String name;
  String val1, val2;

  CustomButton(this.type, this.name, this.val1, [this.val2]);

  String toString() {
    return jsonEncode({
      'type': type,
      'name': name,
      'val1': val1,
      'val2': val2,
    });
  }

  static CustomButton fromString(String data) {
    Map<String, dynamic> d = jsonDecode(data);
    return CustomButton(d['type'], d['name'], d['val1'], d['val2']);
  }
}
