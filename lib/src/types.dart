import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

enum FluxMapUpdateType { devicePosition, devicesStatus }

enum SpeedUnit { kilometersPerHour, knots }

typedef FluxMarkerBuilder = Marker Function(Device device);

typedef DeviceNetworkStatusChangeCallback = void Function(Device device);

typedef MarkerGestureDetectorBuilder = Widget Function(
    BuildContext context, Device device, Widget child);
