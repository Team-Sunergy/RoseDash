import 'package:bt01_serial_test/widgets/gameButton.dart';
import 'package:flutter/material.dart';

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
  );
}
