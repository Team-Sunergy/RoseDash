import 'package:flutter/material.dart';

class TroubleCodes extends StatefulWidget {

  final Stream<List<String>> ctcStream;

  TroubleCodes({required this.ctcStream});

  @override
  createState () => _TroubleCodesState();
}

class _TroubleCodesState extends State<TroubleCodes> {
  List<String>? _ctcs;

  void setTroubleCodes(List<String> ctcs, int id) {
    if (this.mounted) {
          setState(() {
            switch (id) {
              // Delineate between obd2 message types
              case 0:
                _ctcs = ctcs;
                break;
          }});
      }
    }

    @override
    void initState() {
      super.initState();
      widget.ctcStream.listen((ctcs) {
        setTroubleCodes(ctcs, 0);
      });
    }

    @override
    Widget build(BuildContext context) {
      return Column(
        children: [
          Container(
            child: Text("Current Trouble Codes"),
          ),
          Expanded(child:
          ListView.builder(
              itemCount: 1, itemBuilder: (BuildContext context, int index) {
              if (_ctcs != null)
                return  Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _ctcs?.length,
                    itemBuilder: (context, index) {
                      return Text(_ctcs![index]);
                    },
                  )
                ],
              );
              else
                return Container();
          })
          ),
        ],
      );
  }
}