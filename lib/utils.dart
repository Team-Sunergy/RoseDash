import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

IconData btStateIcon(BluetoothState state) {
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
