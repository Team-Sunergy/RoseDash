import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'models.dart';

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

List<String> getCustomButtonsString(SharedPreferences pref) {
  return pref.getStringList(CUSTOM_BUTTON_KEY) ?? [];
}

List<CustomButton> getCustomButtons(SharedPreferences pref) {
  return getCustomButtonsString(pref)
      .map((String e) => CustomButton.fromString(e))
      .toList();
}

Future<void> setCustomButtonsString(
    SharedPreferences pref, List<String> data) async {
  await pref.setStringList(CUSTOM_BUTTON_KEY, data);
}

Future<void> setCustomButtons(
    SharedPreferences pref, List<CustomButton> data) async {
  await setCustomButtonsString(pref, data.map((e) => e.toString()).toList());
}
