import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl_platform_interface/mapbox_gl_platform_interface.dart';

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
    setState(() {
      ready = true;
    });
  }

  Future<void> createMap() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    map = new MapboxMap(initialCameraPosition: CameraPosition(
      target: LatLng(position.latitude, position.longitude), zoom: 20,),
      // boone coordinates LatLng(36.204010,-81.669434)
      accessToken: 'pk.eyJ1Ijoic3Z0YXBwc3RhdGUiLCJhIjoiY2wzYXBzOTgwMDgwYTNrbmo2bHFhYmszeCJ9.H8CwlSNpBsRe4fH7Y4QMPQ',
      styleString: 'mapbox://styles/svtappstate/cl3c61ivy006f14miaq4xr5da',
      onStyleLoadedCallback: () => {doSomething()},
      onUserLocationUpdated: (userLocation) => {
        CameraUpdate.newLatLngZoom(new LatLng(
            userLocation.position.latitude, userLocation.position.longitude),
            13)
      },);
  }

  @override
  Widget build(BuildContext context) {
    return map;
  }
}
