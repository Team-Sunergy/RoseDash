import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TroubleCodes extends StatefulWidget {
  @override
  createState () => _TroubleCodesState();
}

class _TroubleCodesState extends State<TroubleCodes> {
  Set<String>? _ctcs;
  Set<String>? _ptcs;
  Stream _dB = FirebaseFirestore.instance.collection('VisibleTelemetry')
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots(includeMetadataChanges: true);
  void setTroubleCodes(String tcs, int id) {
    if (this.mounted) {
      Iterable<Characters> components = Characters(tcs).replaceAll(Characters("{"), Characters.empty).replaceAll(Characters(" "), Characters.empty).replaceAll(Characters("}"), Characters.empty).split(Characters(","));
      Set<String> s = new Set<String>();
      setState(() {
            switch (id) {
              // Delineate between obd2 message types
              case 0:
                for (Characters c in components) {
                  s.add(c.toString());
                }
                _ctcs = s;
                break;
              case 1:
                for (Characters c in components) {
                  s.add(c.toString());
                }
                _ptcs = s;
                break;
          }});
      }
    }

    void processCodes(QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        if (doc['ptcSet'].toString() != "{}" && doc['ptcSet'] != 0 ) {
          setTroubleCodes(doc['ptcSet'], 1);
        }
        if (doc['ctcSet'].toString() != "{}" && doc['ctcSet'] != 0 ) {
          setTroubleCodes(doc['ctcSet'], 0);
        }
      });
    }

    @override
    void initState() {
      super.initState();
      _dB.listen((event) {
        processCodes(event);
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
                      return Text(_ctcs!.elementAt(index));
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
                      return Text(_ptcs!.elementAt(index));
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