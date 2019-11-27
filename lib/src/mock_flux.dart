import 'dart:async';
import 'dart:math';

import 'package:device/device.dart';
import 'package:flutter/foundation.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geopoint/geopoint.dart';

final Geodesy _geo = Geodesy();
final Random _rnd = Random();

/// Options for the flux to mock
class FluxOptions {
  /// Default constructor
  FluxOptions(
      {this.startingPoint,
      this.bearing = 0.0,
      this.distanceMeters = 100,
      this.intervalSeconds = 1,
      this.aliveTimeout = 5,
      this.sleepingTimeout = 15}) {
    startingPoint ??= GeoPoint(
        latitude: 0.0,
        longitude: 0.0,
        heading: bearing,
        speed: _rnd.nextDouble() * 100,
        timestamp: DateTime.now().millisecondsSinceEpoch);
  }

  /// The point to start from
  GeoPoint startingPoint;

  /// The bearing to go to
  double bearing;

  /// The distance interval
  double distanceMeters;

  /// The time interval
  int intervalSeconds;

  /// The connected timeout
  int aliveTimeout;

  /// The disconnected timeout
  int sleepingTimeout;
}

/// A flux of positions updates for a device
class DeviceFlux {
  /// Default constructor
  DeviceFlux({@required this.fluxSink, @required this.device});

  /// The flux sink to push into
  StreamSink<Device> fluxSink;

  /// The device
  final Device device;
  GeoPoint _lastPosition;

  /// Last position of the device
  GeoPoint get lastPosition => _lastPosition;

  bool _run = false;

  /// Start emiting positions
  Future<void> start({FluxOptions options}) async {
    print("Starting flux for ${device.name}");
    _run = true;
    options ??= FluxOptions();
    // initialize a device
    device
      ..position = options.startingPoint
      ..keepAlive = Duration(seconds: options.aliveTimeout)
      ..sleepingTimeout = Duration(seconds: options.sleepingTimeout);
    //print("FIRST POS = ${device.position}");
    // first position update
    fluxSink.add(device);
    // update loop
    while (_run) {
      await Future<void>.delayed(Duration(seconds: options.intervalSeconds))
          .then((_) {
        final nextPos = _nextPosition(device,
            bearing: options.bearing, distanceMeters: options.distanceMeters);
        //print("NEXT POS = ${nextPos.position}");
        fluxSink.add(nextPos);
        _lastPosition = nextPos.position;
      });
    }
  }

  /// Stop emitting positions
  void stop() {
    print("Stopping flux for ${device.name}");
    _run = false;
  }

  Device _nextPosition(Device device, {double bearing, double distanceMeters}) {
    //device.position ??= GeoPoint(latitude: 0.0, longitude: 0.0);
    //print("NEXT ${device.id} / $bearing");
    final newLatLng = _geo.destinationPointByDistanceAndBearing(
        device.position.toLatLng(), distanceMeters, bearing);
    device.position = GeoPoint(
        latitude: newLatLng.latitude,
        longitude: newLatLng.longitude,
        heading: bearing,
        speed: _rnd.nextDouble() * 100,
        timestamp: DateTime.now().millisecondsSinceEpoch);
    return device;
  }
}

/// A serie of mocked device position flux
class MockFlux {
  /// Default constructor
  MockFlux();

  final StreamController<Device> _deviceFluxController =
      StreamController<Device>();
  final Map<Device, DeviceFlux> _devicesFlux = <Device, DeviceFlux>{};

  /// The stream of devices
  Stream<Device> get stream => _deviceFluxController.stream;

  /// Add a device flux
  DeviceFlux addDeviceFlux(
      {@required String deviceName, @required int deviceId}) {
    final device = Device(name: deviceName, id: deviceId);
    final deviceFlux =
        DeviceFlux(device: device, fluxSink: _deviceFluxController.sink);
    _devicesFlux[device] = deviceFlux;
    return deviceFlux;
  }

  /// Dispose
  void close() => _deviceFluxController.close();
}
