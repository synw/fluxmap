import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// The type of possible state updates
enum FluxMapUpdateType {
  /// Update a device position
  devicePosition,

  /// Update a device status
  devicesStatus
}

/// Speed units
enum SpeedUnit {
  /// km/h
  kilometersPerHour,

  /// knots
  knots
}

/// A marker builder
typedef FluxMarkerBuilder = Marker Function(Device device);

/// Callback on network status change
typedef DeviceNetworkStatusChangeCallback = void Function(Device device);

/// Gesture detector builder for markers
typedef MarkerGestureDetectorBuilder = Widget Function(
    BuildContext context, Device device, Widget child);
