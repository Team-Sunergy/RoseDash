import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';

//BLAEZ COMMENT: I think this class below gathers values from the socStream
//to be used in the SOCMeterState class, which uses values from
//the SOCMeter class to gather info to build and update the widget

class SOCMeter extends StatefulWidget {
  final Stream<double> socStream; //BLAEZ COMMENT: Stream of Data which is collected
  SOCMeter({required this.socStream}); //BLAEZ COMMENT: i think this is a constructor? i think
  @override createState() => _SOCMeterState(); //BLAEZ COMMENT: wtf
}

/// BLAEZ COMMENTS IS ME TRYING TO FIGURE OUT WHAT ANY OF THIS CODE DOES \\\

class _SOCMeterState extends State<SOCMeter> {

  double soc = 82.8; //BLAEZ COMMENT: by default soc is 82.8?

  void setSOC(val) {
    if (this.mounted) //BLAEZ COMMENT: If this.mounted is true
    setState(() {soc = val;}); //BLAEZ COMMENT: then using setState function,
    //set soc to val which is a parameter
  }

  @override
  void initState() {
    super.initState(); //BLAEZ COMMENT: this is overriding the super classes initiate state,
    //it adds in a listener which listens for soc, then sets soc using the above setSOC method
    widget.socStream.listen((soc) {setSOC(soc);});
  }
  @override
  Widget build(BuildContext context) {
    return SfLinearGauge(
        numberFormat: NumberFormat.percentPattern("en_US"),
        orientation: LinearGaugeOrientation.vertical,
        minimum: 0.0,
        maximum: 1.0,
        axisTrackStyle: LinearAxisTrackStyle(
            thickness: 10, color: Colors.white.withOpacity(0.05)),
        //BLAEZ COMMENT - This affects the thickness of the grey widget of the 3rd graph

        barPointers: [
          LinearBarPointer( //this is the first middle widget thing
            enableAnimation: false,
            value: soc / 100, //sets value for the linearBarPointer, which is probably constantly being changed
            edgeStyle: LinearEdgeStyle.endCurve,
            thickness: 4,
            color: Color(0xffedd711),
            borderColor: Color(0xff070b1a),
            borderWidth: 1.25,
          )
        ]);
  }
}