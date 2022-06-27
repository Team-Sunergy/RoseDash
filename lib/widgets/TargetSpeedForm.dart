import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class TargetSpeedForm extends StatefulWidget {
  @override
  State<TargetSpeedForm> createState() => _TargetSpeedFormState();
}

class _TargetSpeedFormState extends State<TargetSpeedForm> {
  CollectionReference _dBIn = FirebaseFirestore.instance.collection('adminSettings');
  Stream _dBOut = FirebaseFirestore.instance.collection('adminSettings')
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots(includeMetadataChanges: true);

  int _targetSpeed = 30;
  int _cts = 30;

  void setCTS(QuerySnapshot snapshot) {
    snapshot.docs.forEach((element) {
      _cts = element['targetSpeed'];
    });
  }

  @override
  void initState() {
    super.initState();
    _dBOut.listen((event) {setCTS(event);});
  }

  Future<void> addTargetSpeed() {
    if (this.mounted) setState(() {
      _cts = _targetSpeed;
    });
    return _dBIn.add({
      'targetSpeed': _targetSpeed,
      'time': DateTime.now()
    });
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
            Container(height: 20,),
            Text('Current Target Speed: $_cts', style: Theme.of(context).textTheme.headline6,),
            Container(height: 50,),
            NumberPicker(
            itemCount: 5,
            selectedTextStyle: TextStyle(color: Color(0xffedd711), fontSize: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey),
            ),
            value: _targetSpeed,
            minValue: 30,
            maxValue: 60,
            step: 1,
            haptics: true,
            infiniteLoop: true,
            onChanged: (value) => setState(() => _targetSpeed = value),
            ),
          Container(height: 50,),
          ElevatedButton(onPressed: () => {addTargetSpeed()}, child: Text('Send to Rose', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),),
          style: ElevatedButton.styleFrom(primary: Color(0xffc2b11d).withOpacity(1)),),
        ],
      ),
    );
  }
}
