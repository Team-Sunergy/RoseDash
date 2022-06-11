import 'package:bt01_serial_test/screens/homePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Warnings extends StatefulWidget {


  final Stream<List<String>> ctcStream;
  final Stream<List<String>> apwiStream;

  Warnings({required this.ctcStream, required this.apwiStream});

  @override
  State<StatefulWidget> createState() => _WarningsState();

}

class _WarningsState extends State<Warnings> {

  late List<String> _ctcs;
  late List<String> _apwi;
  bool warningsSet = false;
  void setTroubleCodes(List<String> warning, int id) {
    if (this.mounted) {
      setState(() {
        warningsSet = true;
        switch (id) {
        // Delineate between obd2 message types
          case 0:
            _ctcs = warning;
            break;
          case 1:
            _apwi = warning;
            break;
        }});
    }
  }

  void updateView() { HomePage.leftIndex = 2; }

  @override
  void initState() {
    super.initState();
    widget.ctcStream.listen((ctcs) {
      setTroubleCodes(ctcs, 0);
    });
    widget.ctcStream.listen((apwi) {
      setTroubleCodes(apwi, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (warningsSet) {
      if (_ctcs.isNotEmpty && _apwi.isNotEmpty) {
        return Container(margin: EdgeInsets.symmetric(vertical: 10,),
          child: Row(
              children: [
                IconButton(onPressed: () => {updateView()}, icon: Icon(IconData(0xe7ce, fontFamily: 'MaterialIcons'),
                  size: 48, semanticLabel: "Aux Pack LOW",  color: Colors.red,)),
                Container(width: 50),
                IconButton(onPressed: () => {updateView()}, icon: Icon(IconData(0xe6cc, fontFamily: 'MaterialIcons'),
                  size: 48, semanticLabel: "Battery Fault",  color: Colors.red,))
              ]),
        ); // BPS fault and Aux low indicator
      } else if (_ctcs.isNotEmpty) {
        return Container(margin: EdgeInsets.symmetric(vertical: 10,),
          child: Row(
              children: [
                IconButton(onPressed: () => {updateView()}, icon: Icon(IconData(0xe6cc, fontFamily: 'MaterialIcons'),
                  size: 48, semanticLabel: "Battery Fault",  color: Colors.red,))
              ]),
        ); // BPS fault and Aux low indicator
      } else if (_apwi.isNotEmpty) {
        return Container(margin: EdgeInsets.symmetric(vertical: 10,),
          child: Row(
              children: [
                IconButton(onPressed: () => {updateView()}, icon: Icon(IconData(0xe7ce, fontFamily: 'MaterialIcons'),
                  size: 48, semanticLabel: "Aux Pack LOW",  color: Colors.red,)),
                Container(width: 50),
              ]),
        ); // BPS fault and Aux low indicator
      } else { return Container();}
    } else { return Container(margin: EdgeInsets.symmetric(vertical: 10,),
      child: Row(
          children: [
            if (warningsSet)
              IconButton(onPressed: () => {updateView()}, icon: Icon(IconData(0xe7ce, fontFamily: 'MaterialIcons'),
                  size: 48, semanticLabel: "Aux Pack LOW",  color: Colors.red,)),
              Container(width: 50),
              if (warningsSet)
              IconButton(onPressed: () => {updateView()}, icon: Icon(IconData(0xe6cc, fontFamily: 'MaterialIcons'),
                size: 48, semanticLabel: "Battery Fault",  color: Colors.red,))
          ]),
    ); }
  }
}