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
