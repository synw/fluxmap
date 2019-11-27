import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluxmap/fluxmap.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_controller/map_controller.dart';
import 'package:latlong/latlong.dart';
import 'package:geopoint/geopoint.dart';
import 'package:err/err.dart';

import 'package:device/device.dart';

final ErrRouter log = ErrRouter(channel: ErrChannel.dev);

class _MapPageState extends State<MapPage> {
  final device = Device(
      name: "phone 1",
      position: GeoPoint(latitude: 0.0, longitude: 0.0, speed: 31.0));

  _MapPageState() {
    map = StatefulMapController(mapController: MapController());
    flux = FluxMapState(
        map: map,
        onDeviceDisconnect: (device) =>
            log.flash("Device ${device.name} is disconnected"),
        onDeviceOffline: (device) =>
            log.flash("Device ${device.name} is offline"),
        onDeviceBackOnline: (device) =>
            log.flash("Device ${device.name} is back online"),
        markerHeight: 85.0,
        markerWidth: 100.0,
        markerGestureDetectorBuilder: (context, device, child) {
          return GestureDetector(
              child: child,
              onTap: () {
                log.debugFlash("Tap $device");
              },
              onDoubleTap: () {
                log.debugFlash("Double tap $device");
              },
              onLongPress: () {
                log.debugFlash("Long press $device");
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
    _deviceFlux1 = _devicesFlux.addDeviceFlux(
        deviceId: 1, deviceName: "device 1")
      ..start(
          options: FluxOptions(
              intervalSeconds: 3,
              startingPoint: GeoPoint.fromLatLng(point: _center)));
    _deviceFlux2 = _devicesFlux.addDeviceFlux(
        deviceId: 2, deviceName: "device 2")
      ..start(
          options: FluxOptions(
              bearing: 30.0,
              startingPoint: GeoPoint.fromLatLng(point: _center)));
    _deviceFlux3 = _devicesFlux.addDeviceFlux(
        deviceId: 3, deviceName: "device 3")
      ..start(
          options: FluxOptions(
              bearing: 10.0,
              startingPoint: GeoPoint.fromLatLng(point: _center)));
    await Future<void>.delayed(const Duration(seconds: 3));
    _deviceFlux1.stop();
    await Future<void>.delayed(const Duration(seconds: 8));
    _deviceFlux2.stop();
    await Future<void>.delayed(const Duration(seconds: 20));
    _deviceFlux1.start(
        options: FluxOptions(
            bearing: 180.0, startingPoint: _deviceFlux1.lastPosition));
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
        body: FluxMap(
            center: _center,
            zoom: 14.0,
            state: flux,
            devicesFlux: _devicesFlux.stream));
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
