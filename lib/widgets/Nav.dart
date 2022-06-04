import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'dart:async';

class Nav extends StatefulWidget {
  @override
  createState() => _NavState();
}

class _NavState extends State<Nav> {
bool ready = false;
late MapboxMap map;
  @override
  void initState() {
    super.initState();
    createMap();
  }

  void doSomething() {
    setState((){
      ready = true;
    });
  }
 Future<void> createMap() async{
   map = new MapboxMap(initialCameraPosition: CameraPosition(target: LatLng(39.0921803,-94.4170527)),
     accessToken: 'pk.eyJ1Ijoic3Z0YXBwc3RhdGUiLCJhIjoiY2wzYXBzOTgwMDgwYTNrbmo2bHFhYmszeCJ9.H8CwlSNpBsRe4fH7Y4QMPQ',
     styleString: 'mapbox://styles/svtappstate/cl3c61ivy006f14miaq4xr5da',
     onStyleLoadedCallback: () => {doSomething()},);
   setState((){});
 }
  @override
  Widget build(BuildContext context) {
   return map;
  }
}