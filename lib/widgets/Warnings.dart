//@dart=2.9
import 'package:bt01_serial_test/screens/homePage.dart';
import 'package:flutter/material.dart';

class Warnings extends StatefulWidget {


  final Stream<Set<String>> ctcStream;
  final Stream<Set<String>> ptcStream;
  final Stream<String> apwiStream;
  final Function() callback;
  Warnings({this.ctcStream, this.ptcStream, this.apwiStream, this.callback});

  @override
  State<StatefulWidget> createState() => _WarningsState();

}

class _WarningsState extends State<Warnings> {

  bool tcSet = false;
  bool apwSet = false;

  void setTroubleCodes(bool warning, int id) {
    if (this.mounted) {
      setState(() {
        switch (id) {
        // Delineate between obd2 message types
          case 0:
            if (warning) tcSet = true;
            else tcSet = false;
            break;
          case 1:
            if (warning) apwSet = true;
            else apwSet = false;
            break;
        }
      });
    }
  }

// Invoke the callback of the Parent Widget
  void updateView() {
    widget.callback.call();
  }

  @override
  void initState() {
    super.initState();
    widget.ctcStream.listen((ctcs) {
      setTroubleCodes(ctcs.isNotEmpty, 0);
    });
    widget.ptcStream.listen((ptcs) {
      setTroubleCodes(ptcs.isNotEmpty, 0);
    });
    widget.apwiStream.listen((apwi) {
      setTroubleCodes(apwi != "", 1);
    });
  }

  @override
  Widget build(BuildContext context) {
        if (tcSet && apwSet) {
          return Container(margin: EdgeInsets.symmetric(vertical: 10,),
            child: Row(
                children: [
                  IconButton(onPressed: () => {updateView()},
                      icon: Icon(IconData(0xe7ce, fontFamily: 'MaterialIcons'),
                        size: 48,
                        semanticLabel: "Aux Pack LOW",
                        color: Colors.red,)),
                  Container(width: 50),
                  IconButton(onPressed: () => {updateView()},
                      icon: Icon(IconData(0xe6cc, fontFamily: 'MaterialIcons'),
                        size: 48,
                        semanticLabel: "Battery Fault",
                        color: Colors.red,))
                ]),
          ); // BPS fault and Aux low indicator
        } else if (tcSet) {
          return Container(margin: EdgeInsets.symmetric(vertical: 10,),
            child: Row(
                children: [
                  Container(width: 98,),
                  IconButton(onPressed: () => {updateView()},
                      icon: Icon(IconData(0xe6cc, fontFamily: 'MaterialIcons'),
                        size: 48,
                        semanticLabel: "Battery Fault",
                        color: Colors.red,))
                ]),
          ); // BPS fault and Aux low indicator
        } else if (apwSet) {
          return Container(margin: EdgeInsets.symmetric(vertical: 10,),
            child: Row(
                children: [
                  IconButton(onPressed: () => {updateView()},
                      icon: Icon(IconData(0xe7ce, fontFamily: 'MaterialIcons'),
                        size: 48,
                        semanticLabel: "Aux Pack LOW",
                        color: Colors.red,)),
                  Container(width: 50),
                ]),
          ); // BPS fault and Aux low indicator
        } else {
          return Container();
        }
  }
}