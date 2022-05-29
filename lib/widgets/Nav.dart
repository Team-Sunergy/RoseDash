import 'package:flutter/material.dart';
// Navigation Imports
import 'package:flutter_map/flutter_map.dart';
import "package:latlong2/latlong.dart" as latLng;
// Offline Maps
import 'package:cached_network_image/cached_network_image.dart';


class Nav extends StatefulWidget {
  @override createState() => _NavState();
}

class _NavState extends State<Nav> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        //center: latLng.LatLng(56.1304, 106.3468),
        center: latLng.LatLng(36.221366, -81.644684),
        zoom: 13.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://api.mapbox.com/styles/v1/svtappstate/cl3ewi1da003215o6b97pbc56/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3Z0YXBwc3RhdGUiLCJhIjoiY2wzYXBzOTgwMDgwYTNrbmo2bHFhYmszeCJ9.H8CwlSNpBsRe4fH7Y4QMPQ",
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              //point: latLng.LatLng(56.1304, 106.3468),
              point: latLng.LatLng(36.221366, -81.644684),
              builder: (ctx) =>
                  Container(
                  ),
            ),
          ],
        ),
      ],
    );
  }
}