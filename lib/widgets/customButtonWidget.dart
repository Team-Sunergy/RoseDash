import 'package:flutter/material.dart';

import '../models.dart';
import 'gameButton.dart';

Widget customButtonWidget(CustomButton b, dynamic onTap) {
  if (b.type == 0) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(b.name, textScaleFactor: 2.0),
        gameButton("OFF", (TapDownDetails details) {
          onTap(b.val1);
        }),
        gameButton("ON ", (TapDownDetails details) {
          onTap(b.val2);
        }),
      ],
    );
  } else if (b.type == 1) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        gameButton(b.name, (TapDownDetails details) {
          onTap(b.val1);
        })
      ],
    );
  } else {
    return Container();
  }
}
