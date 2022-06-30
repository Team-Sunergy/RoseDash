import 'dart:collection';

import 'package:flutter/material.dart';

HashMap<String, String> faultCodes = new HashMap<String, String>();

class TroubleCodes extends StatefulWidget {

  final Stream<Set<String>> ctcStream;
  final Stream<Set<String>> ptcStream;

  TroubleCodes({required this.ctcStream, required this.ptcStream});

  @override
  createState () => _TroubleCodesState();
}

class _TroubleCodesState extends State<TroubleCodes> {
  Set<String>? _ctcs;
  Set<String>? _ptcs;

  void setTroubleCodes(Set<String> tcs, int id) {
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

  String _codeLookup(String code)
  {
    String returnValue = "Unknown Fault Code Error!";
    faultCodes.forEach((key, value) {
      if (code == key)
      {
        value = returnValue;
      }
    });
    return returnValue;
  }

    @override
    void initState() {
      super.initState();
      _initHashMap();
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
                      return Text(_codeLookup(_ptcs!.elementAt(index)));
                      //return Text(_ptcs!.elementAt(index));
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

_initHashMap() {
  faultCodes["P0A0C"] = "Highest Cell Voltage Too High Fault";
  faultCodes["P0A0E"] = "Lowest Cell Voltage Too Low Fault";
  faultCodes["P0A10"] = "Pack Too Hot Fault";
  faultCodes["P0A0F"] = "Cell ASIC Fault";
  faultCodes["P0ACA"] = "Charge Interlock Fault";
  faultCodes["P0A0D"] = "Cell Voltage Over 5 Volts";
  faultCodes["P0A04"] = "Open Wiring Fault (or “Open Cell Voltage Fault”)";
  faultCodes["P0A03"] = "Pack Voltage Mismatch Error";
  faultCodes["P0A80"] = "Weak Cell Fault";
  faultCodes["P0A0B"] = "Internal Software Fault";
  faultCodes["P0A0A"] = "Internal Heatsink Thermistor Fault";
  faultCodes["P0A09"] = "Internal Hardware Fault";
  faultCodes["P0A12"] = "Cell Balancing Stuck Off";
  faultCodes["P0AC0"] = "Current Sensor Fault";
  faultCodes["P0A1F"] = "Internal Cell Communication Fault";
  faultCodes["P0AFA"] = "Low Cell Voltage Fault";
  faultCodes["P0AA6"] = "High Voltage Isolation Fault";
  faultCodes["P0A01"] = "Pack Voltage Sensor Fault";
  faultCodes["P0A02"] = "Weak Pack Fault";
  faultCodes["P0A81"] = "Fan Monitor Fault";
  faultCodes["U0100"] = "External Communication Fault";
  faultCodes["P0560"] = "Redundant Power Supply Fault";
  faultCodes["P0A05"] = "Input Power Supply Fault";
  faultCodes["P0A06"] = "Charge Limit Enforcement Fault";
  faultCodes["P0A07"] = "Discharge Limit Enforcement Fault";
  faultCodes["P0A08"] = "Charger Safety Relay Fault";
  faultCodes["P0A9C"] = "Battery Thermistor Fault";
}


