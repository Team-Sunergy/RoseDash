import 'package:flutter/material.dart';

class TroubleCodes extends StatefulWidget {

  final Stream<int> tcStream0;
  final Stream<int> tcStream1;
  final Stream<int> tcStream2;
  final Stream<int> tcStream3;
  final Stream<int> tcStream4;

  TroubleCodes({required this.tcStream0,
    required this.tcStream1,
    required this.tcStream2,
    required this.tcStream3,
    required this.tcStream4,});

  @override
  createState () => _TroubleCodesState();
}

class _TroubleCodesState extends State<TroubleCodes> {
  late int _tc0;
  late int _tc1;
  late int _tc2;
  late int _tc3;
  late int _tc4;

  void setTroubleCodes(int tc, int id) {
    if (this.mounted) {

          setState(() {
            switch (id) {
              case 0:
                _tc0 = tc;
                break;
              case 1:
                _tc1 = tc;
                break;
              case 2:
                _tc2 = tc;
                break;
              case 3:
                _tc3 = tc;
                break;
              case 4:
                _tc4 = tc;
                break;
          }});
      }
    }

    @override
    void initState() {
      super.initState();
      _tc0 = _tc1 = _tc2 = _tc3 = _tc4 = 2;
      widget.tcStream0.listen((tc0) {
        setTroubleCodes(tc0, 0);
      });
      widget.tcStream1.listen((tc1) {
        setTroubleCodes(tc1, 1);
      });
      widget.tcStream2.listen((tc2) {
        setTroubleCodes(tc2, 2);
      });
      widget.tcStream3.listen((tc3) {
        setTroubleCodes(tc3, 3);
      });
      widget.tcStream4.listen((tc4) {
        setTroubleCodes(tc4, 4);
      });
    }

    @override
    Widget build(BuildContext context) {
      return ListView.builder(
          itemCount: 1, itemBuilder: (BuildContext context, int index) {
          return  Column(
            children: [
              Text(
                    "Trouble Code ID1: " + _tc0.toString(),
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 15),),
              Text(
                "Trouble Code ID2: " + _tc1.toString(),
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 15),),
              Text(
                "Trouble Code ID3: " + _tc2.toString(),
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 15),),
              Text(
                "Trouble Code ID4: " + _tc3.toString(),
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 15),),
              Text(
                "Trouble Code ID5: " + _tc4.toString(),
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 15),),
            ],
          );
    });
  }
}