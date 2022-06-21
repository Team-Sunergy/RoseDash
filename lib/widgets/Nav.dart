//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:cloud_firestore/cloud_firestore.dart';

class Nav extends StatefulWidget {

  @override
  createState() => _NavState();
}

class _NavState extends State<Nav> {
  Stream _dB = FirebaseFirestore.instance.collection('VisibleTelemetry')
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots(includeMetadataChanges: true);
  bool ready = false;
  Circle? _circle;
  Circle? _roseCircle;
  late MapboxMap map;
  late StreamSubscription<gl.Position> positionStream;
  late MapboxMapController _mapController;
  gl.Position position = new gl.Position(accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, timestamp: DateTime.now(), latitude: 36.204010, longitude: -81.669434);


  Future<LatLng> acquireCurrentLocation() async {
    return LatLng(position.latitude, position.longitude);
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }
  @override
  void initState() {
    super.initState();
    positionStream  = gl.Geolocator.getPositionStream(locationSettings: gl.LocationSettings(accuracy: gl.LocationAccuracy.best))
        .listen((gl.Position position) {
      // Handle position changes
      setMyLocation(position);
    });
    _dB.listen((event) {extractRoseLoc(event);});
    createMap();
  }

  void extractRoseLoc(QuerySnapshot snapshot) {
    double lat = 0;
    double long = 0;
    snapshot.docs.forEach((element) {
      lat = double.parse(element['lat'].toString());
      long = double.parse(element['long'].toString());
    });
    setRoseLocation(lat, long);
  }

  void setMyLocation(gl.Position location) {
    if (this.mounted)
      setState(() {
        position = location;
        setMyCam();
      });
  }

  void setRoseLocation(double lat, double long) {
    if (this.mounted)
      setState(() {
        setRoseCam(lat, long);
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

  Future<void> setMyCam() async {
    await _mapController.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
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
  }

  Future<void> setRoseCam(double lat, double long) async {

    if (false) {
      await _mapController.animateCamera(
          CameraUpdate.newLatLng(
              LatLng(position.latitude, position.longitude)));
    }
    if (_roseCircle != null) {
      await _mapController.removeCircle(_roseCircle!);
    }

    // Add a circle denoting current user location
    _roseCircle = await _mapController.addCircle( CircleOptions(
      circleRadius: 8.0,
      circleColor: '#DEC20B',
      circleOpacity: 0.8,

      // YOU NEED TO PROVIDE THIS FIELD!!!
      // Otherwise, you'll get a silent exception somewhere in the stack
      // trace, but the parameter is never marked as @required, so you'll
      // never know unless you check the stack trace
      geometry: LatLng(lat, long),
      draggable: false,
    ));
  }
}
