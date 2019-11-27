import 'package:device/device.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';
import 'package:rxdart/rxdart.dart';

import 'default_marker_builder.dart';
import 'defaults_settings.dart';
import 'types.dart';

/// The state of the map
class FluxMapState {
  /// Default constructor
  FluxMapState(
      {this.map,
      this.markerBuilder,
      this.markerGestureDetectorBuilder,
      this.markerWidth = 60.0,
      this.markerHeight = 56.0,
      this.alignMarker = AnchorAlign.top,
      this.onDeviceDisconnect,
      this.onDeviceOffline,
      this.onDeviceBackOnline}) {
    map ??= StatefulMapController(mapController: MapController());
    _markersRebuildSignal
        .debounceTime(const Duration(milliseconds: 200))
        .listen((_) {
      _rebuildMarkers();
    });
  }

  /// The map controller
  StatefulMapController map;

  /// A builder for marker gestures
  MarkerGestureDetectorBuilder markerGestureDetectorBuilder;

  /// A builder for markers updates
  FluxMarkerBuilder markerBuilder;

  /// The width of a marker
  double markerWidth;

  /// The height of a marker
  double markerHeight;

  /// The alignment of a marker
  AnchorAlign alignMarker;

  /// A callback for when a device disconnect
  DeviceNetworkStatusChangeCallback onDeviceDisconnect;

  /// A callback for when a device goes offline
  DeviceNetworkStatusChangeCallback onDeviceOffline;

  /// A callback for when a device comes back online
  DeviceNetworkStatusChangeCallback onDeviceBackOnline;

  final _firstPositionUpdateForDevices = <int>[];
  final _markersRebuildSignal = PublishSubject<bool>();

  /// All the devices
  Map<int, Device> devices = <int, Device>{};

  /// The first position update
  bool firstPositionUpdateDone = false;

  /// Initial center on the map
  LatLng center;

  /// Initial zoom on the map
  double zoom;

  // **********************************
  // Status loop
  // **********************************

  /// rebuild markers if a device status has changed
  void checkDevicesStatus() {
    for (final device in devices.values) {
      final current = device.networkStatus;
      final last =
          device.properties["last_network_status"] as DeviceNetworkStatus;
      //print(
      //    "${devices.length} Device ${device.id} / $dns / ${device.networkStatus}");
      switch (last == current) {
        case false:
          // watch state changes for callbacks to trigger
          if (onDeviceDisconnect != null) {
            if (current == DeviceNetworkStatus.disconnected) {
              onDeviceDisconnect(device);
            }
          }
          if (onDeviceOffline != null) {
            if (current == DeviceNetworkStatus.offline) {
              onDeviceOffline(device);
            }
          }
          if (onDeviceBackOnline != null) {
            if ((last == DeviceNetworkStatus.disconnected ||
                    last == DeviceNetworkStatus.offline) &&
                current == DeviceNetworkStatus.online) {
              onDeviceBackOnline(device);
            }
          }
          // update old status
          device.properties["last_network_status"] = current;
          // refresh markers
          _markersRebuildSignal.sink.add(true);
          return;
          break;
        default:
      }
    }
  }

  // **********************************
  // Position
  // **********************************

  /// Update devices position actions
  Future<void> updateDevicePosition(Device _device,
      {SpeedUnit speedUnit = SpeedUnit.kilometersPerHour,
      bool verbose = false}) async {
    assert(_device.id != null);
    if (verbose) {
      print("Position update for device:");
      _device.describe();
    }
    if (speedUnit == SpeedUnit.knots) {
      // convert from knots
      _device.position.speed = _device.speed * 1.852;
    }
    // skip invalid point
    if ((_device.position?.speed ?? 0) > maxReasonableSpeed) {
      return;
    }
    // check if the device object is known
    Device device;
    if (devices.containsKey(_device.id)) {
      device = devices[_device.id]
        ..position = _device.position
        ..batteryLevel = _device.batteryLevel;
    } else {
      _device.properties["last_network_status"] = _device.networkStatus;
      device = _device
        //..sleepingTimeout = defaultSleepingTimeout
        //..keepAlive = defaultKeepAlive
        ..properties = _device.properties;
      devices[device.id] = device;
    }
    _markersRebuildSignal.sink.add(true);
    // init stoff
    if (!_firstPositionUpdateForDevices.contains(device.id)) {
      _firstPositionUpdateForDevices.add(device.id);
    }
    // fit markers on map if first launch
    if (!firstPositionUpdateDone) {
      if (_firstPositionUpdateForDevices.length == devices.length) {
        //unawaited(map.fitMarkers());
        firstPositionUpdateDone = true;
      }
    }
  }

  /// Finish using
  void dispose() => _markersRebuildSignal.close();

  // **********************************
  // Internal methods
  // **********************************

  void _rebuildMarkers() {
    final m = <String, Marker>{};
    devices.forEach((id, d) {
      if (markerBuilder == null) {
        m["$id"] = defaultMarkerBuilder(d, markerGestureDetectorBuilder,
            markerWidth, markerHeight, alignMarker);
      } else {
        m["$id"] = markerBuilder(d);
      }
    });
    map.addMarkers(markers: m);
  }
}
