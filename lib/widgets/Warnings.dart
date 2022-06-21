//@dart=2.9
import 'package:bt01_serial_test/screens/homePage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Warnings extends StatefulWidget {



  final Function() callback;
  Warnings({this.callback});

  @override
  State<StatefulWidget> createState() => _WarningsState();

}

class _WarningsState extends State<Warnings> {

  Stream _dB = FirebaseFirestore.instance.collection('VisibleTelemetry')
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots(includeMetadataChanges: true);

  bool tcSet = false;
  bool apwSet = false;

  void setTroubleCodes(QuerySnapshot snapshot) {
    if (this.mounted) {
      setState(() {
        snapshot.docs.forEach((element) {
          if (element['apvSet'] != "" && element['apvSet'] != 0) {
            apwSet = true;
          } else
          {
            apwSet = false;
          }
          if ((element['ctcSet'].toString() != "{}" ||
              element['ptcSet'].toString() != "{}") &&
              (element['ctcSet'] != 0 ||
              element['ptcSet'] != 0)) {
            print(element['ctcSet'].toString());
            tcSet = true;
          } else
          {
            tcSet = false;
          }
        });

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
    _dB.listen((event) {
      setTroubleCodes(event);
    });
  }

  @override
  Widget build(BuildContext context) {
        if (tcSet && apwSet) {
          return Container(margin: EdgeInsets.symmetric(vertical: 10),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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