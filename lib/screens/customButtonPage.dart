import 'package:bt01_serial_test/utils.dart';
import 'package:bt01_serial_test/widgets/gameButton.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models.dart';

class CustomButtonPage extends StatefulWidget {
  final SharedPreferences pref;
  CustomButtonPage(this.pref);
  @override
  State<StatefulWidget> createState() => CustomButtonPageState();
}

class CustomButtonPageState extends State<CustomButtonPage> {
  List<CustomButton> buttons = [];
  int _idx = -1;
  int _type = 0;
  TextEditingController _nameC = TextEditingController(text: "Create New");
  TextEditingController _val1C = TextEditingController(text: "0");
  TextEditingController _val2C = TextEditingController(text: "1");

  @override
  void initState() {
    super.initState();
    buttons = getCustomButtons(widget.pref);
  }

  @override
  void dispose() {
    _nameC?.dispose();
    _val1C?.dispose();
    _val2C?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        actions: [
          IconButton(
            icon: Icon(Icons.save_outlined),
            onPressed: () {
              setCustomButtons(widget.pref, buttons).then((_) {
                Navigator.of(context).pop();
              });
            },
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            ListTile(
              tileColor: Colors.blueGrey[900],
              leading: _idx < 0
                  ? DropdownButton(
                      value: _type,
                      onChanged: (value) {
                        setState(() {
                          _type = value;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          child: Text("0"),
                          value: 0,
                        ),
                        DropdownMenuItem(
                          child: Text("1"),
                          value: 1,
                        ),
                      ],
                    )
                  : Text("$_type"),
              title: TextField(
                controller: _nameC,
                maxLength: 25,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                  counterText: '',
                ),
              ),
              subtitle: _type == 0
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                            child: TextField(
                          controller: _val1C,
                          maxLength: 5,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'OFF',
                            counterText: '',
                          ),
                        )),
                        Expanded(
                            child: TextField(
                          controller: _val2C,
                          maxLength: 5,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ON',
                            counterText: '',
                          ),
                        )),
                      ],
                    )
                  : TextField(
                      controller: _val1C,
                      maxLength: 10,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'OnTap',
                        counterText: '',
                      ),
                    ),
              trailing: Row(
                children: [
                  gameButton(
                    _idx < 0 ? "Add" : "Save",
                    (TapDownDetails _) {
                      if (_idx < 0) {
                        buttons.add(CustomButton(
                            _type, _nameC.text, _val1C.text, _val2C.text));
                      } else {
                        buttons[_idx].name = _nameC.text;
                        buttons[_idx].val1 = _val1C.text;
                        buttons[_idx].val2 = _val2C.text;
                      }
                      _idx = -1;
                      _nameC.text = "Create New";
                      _val1C.text = "0";
                      _val2C.text = "1";
                      setState(() {});
                    },
                  )
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
            Container(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: buttons.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    leading: Text("${buttons[i].type}"),
                    title: Text(buttons[i].name),
                    subtitle: Text(buttons[i].type == 0
                        ? "ON: ${buttons[i].val1}  OFF: ${buttons[i].val2}"
                        : "OnPressed: ${buttons[i].val1}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_forever),
                      onPressed: () {
                        buttons.removeAt(i);
                        setState(() {});
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _idx = _idx == i ? -1 : i;
                        if (_idx == i) {
                          _type = buttons[i].type;
                          _nameC.text = buttons[i].name;
                          _val1C.text = buttons[i].val1;
                          _val2C.text = buttons[i].val2;
                        } else {
                          _nameC.text = "Create New";
                          _val1C.text = "0";
                          _val2C.text = "1";
                        }
                      });
                    },
                    selected: _idx == i,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
