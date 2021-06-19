import 'package:flutter/material.dart';

Widget gameButton(
  String text,
  GestureTapDownCallback onTap,
) {
  return GestureDetector(
    onTapDown: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          text,
          textScaleFactor: 2.0,
        ),
      ),
    ),
  );
}
