import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl_platform_interface/mapbox_gl_platform_interface.dart';

class Nav extends StatefulWidget {

  @override
  createState() => _NavState();
}

class _NavState extends State<Nav> {
  bool ready = false;
  Circle? _circle;
  late Circle _userPos;
  late MapboxMap map;
  late StreamSubscription<Position> positionStream;
  late MapboxMapController _mapController;
  Position position = new Position(accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, timestamp: DateTime.now(), latitude: 20, longitude: 20);


  Future<LatLng> acquireCurrentLocation() async {
    return LatLng(position.latitude, position.longitude);
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }
  @override
  void initState() {
    super.initState();
    positionStream  = Geolocator.getPositionStream()
        .listen((Position position) {
      // Handle position changes
      setLocation(position);
    });
    createMap();
  }

  void setLocation(Position location) {
    print(location.heading);
    if (this.mounted)
    setState(() async {
      position = location;
      await _mapController.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
      if (_circle != null) {
        await _mapController.removeCircle(_circle!);
      }
      // Add a circle denoting current user location
      _circle = await _mapController.addCircle( CircleOptions(
        circleRadius: 8.0,
        circleColor: '#006992',
        circleOpacity: 0.8,

        // YOU NEED TO PROVIDE THIS FIELD!!!
        // Otherwise, you'll get a silent exception somewhere in the stack
        // trace, but the parameter is never marked as @required, so you'll
        // never know unless you check the stack trace
        geometry: LatLng(position.latitude, position.longitude),
        draggable: false,
      ));

    });
  }

  void createMap() {
    map = new MapboxMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 13,),
      // boone coordinates LatLng(36.204010,-81.669434)
      accessToken: 'pk.eyJ1Ijoic3Z0YXBwc3RhdGUiLCJhIjoiY2wzYXBzOTgwMDgwYTNrbmo2bHFhYmszeCJ9.H8CwlSNpBsRe4fH7Y4QMPQ',
      styleString: 'mapbox://styles/svtappstate/cl3c61ivy006f14miaq4xr5da',
      onStyleLoadedCallback: () => {},
      trackCameraPosition: true,
      onMapCreated: (controller) {
       _onMapCreated(controller);
      }
      );
  }

  @override
  Widget build(BuildContext context) {
    return map;
  }

  @override
  void dispose() {
    super.dispose();
    positionStream.cancel();
  }

}