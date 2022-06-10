import 'package:flutter/material.dart';

class TroubleCodes extends StatefulWidget {

  final Stream<List<String>> ctcStream;
  final Stream<List<String>> ptcStream;

  TroubleCodes({required this.ctcStream, required this.ptcStream});

  @override
  createState () => _TroubleCodesState();
}

class _TroubleCodesState extends State<TroubleCodes> {
  List<String>? _ctcs;
  List<String>? _ptcs;

  void setTroubleCodes(List<String> tcs, int id) {
    if (this.mounted) {
          setState(() {
            switch (id) {
              // Delineate between obd2 message types
              case 0:
                _ctcs = tcs;
                break;
              case 1:
                _ptcs = tcs;
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
      widget.ctcStream.listen((ptcs) {
        setTroubleCodes(ptcs, 1);
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
          Container(
            child: Text("Pending Trouble Codes"),
          ),
          Expanded(child:
          ListView.builder(
              itemCount: 1, itemBuilder: (BuildContext context, int index) {
            if (_ptcs != null)
              return  Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _ptcs?.length,
                    itemBuilder: (context, index) {
                      return Text(_ptcs![index]);
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