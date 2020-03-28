import 'dart:async';

import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluxmap/fluxmap.dart';
import 'package:geopoint/geopoint.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';
import 'package:pedantic/pedantic.dart';

class _MapPageState extends State<MapPage> {
  final Device device = Device(
      name: "phone 1",
      position: GeoPoint(latitude: 0.0, longitude: 0.0, speed: 31.0));

  var _statusMsg = "Simulation started";

  _MapPageState() {
    map = StatefulMapController(mapController: MapController());
    flux = FluxMapState(
        map: map,
        onDeviceDisconnect: (device) {
          print("DEVICE DISCONN $device");
          setState(() => _statusMsg = "${device.name} is disconnected");
        },
        onDeviceOffline: (device) {
          print("DEVICE OFFL $device");
          setState(() => _statusMsg = "${device.name} is offline");
        },
        onDeviceBackOnline: (device) =>
            setState(() => _statusMsg = "${device.name} is back online"),
        markerHeight: 85.0,
        markerWidth: 100.0,
        markerGestureDetectorBuilder: (context, device, child) {
          return GestureDetector(
              child: child,
              onTap: () {
                print("Tap $device");
              },
              onDoubleTap: () {
                print("Double tap $device");
              },
              onLongPress: () {
                print("Long press $device");
              });
        });
  }

  final _devicesFlux = MockFlux();
  DeviceFlux _deviceFlux1;
  DeviceFlux _deviceFlux2;
  DeviceFlux _deviceFlux3;

  StatefulMapController map;
  FluxMapState flux;
  final _center = LatLng(11.0, 0.0);

  Future<void> startLocationUpdates() async {
    _deviceFlux1 =
        _devicesFlux.addDeviceFlux(deviceId: 1, deviceName: "device 1");
    unawaited(_deviceFlux1.start(
        options: FluxOptions(
            intervalSeconds: 3,
            startingPoint: GeoPoint.fromLatLng(point: _center))));
    _deviceFlux2 =
        _devicesFlux.addDeviceFlux(deviceId: 2, deviceName: "device 2");
    unawaited(_deviceFlux2.start(
        options: FluxOptions(
            bearing: 30.0,
            startingPoint: GeoPoint.fromLatLng(point: _center))));
    _deviceFlux3 =
        _devicesFlux.addDeviceFlux(deviceId: 3, deviceName: "device 3");
    unawaited(_deviceFlux3.start(
        options: FluxOptions(
            bearing: 10.0,
            startingPoint: GeoPoint.fromLatLng(point: _center))));
    await Future<void>.delayed(const Duration(seconds: 3));
    _deviceFlux1.stop();
    await Future<void>.delayed(const Duration(seconds: 8));
    _deviceFlux2.stop();
    await Future<void>.delayed(const Duration(seconds: 20));
    unawaited(_deviceFlux1.start(
        options: FluxOptions(
            bearing: 180.0, startingPoint: _deviceFlux1.lastPosition)));
  }

  @override
  void initState() {
    print("Init Fluxmap state");
    super.initState();
    flux.map.addMarker(
        name: "m",
        marker: Marker(
            point: _center,
            builder: (BuildContext context) =>
                Icon(Icons.star, color: Colors.yellow)));
    print("Starting location updates");
    startLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    print("Build map");
    return Scaffold(
        body: Stack(children: <Widget>[
      FluxMap(
          center: _center,
          zoom: 14.0,
          state: flux,
          devicesFlux: _devicesFlux.stream),
      Positioned(
          bottom: 25.0,
          left: 25.0,
          child: Text(_statusMsg, textScaleFactor: 1.2))
    ]));
  }

  @override
  void dispose() {
    _deviceFlux1.stop();
    _deviceFlux2.stop();
    _deviceFlux3.stop();
    _devicesFlux.close();
    flux.dispose();
    super.dispose();
  }
}

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}
