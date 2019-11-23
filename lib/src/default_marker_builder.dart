import 'package:flutter/material.dart';
import 'package:device/device.dart';
import 'package:flutter_map/flutter_map.dart';
import 'types.dart';

Marker defaultMarkerBuilder(
    Device device, MarkerGestureDetectorBuilder markerGestureDetectorBuilder) {
  assert(device != null);
  if (device.position == null) {
    throw ArgumentError.notNull();
  }
  if (device.position.point == null) {
    throw ArgumentError.notNull();
  }
  Color markerColor;
  var markerIcon = Icons.location_on;
  switch (device.networkStatus) {
    case DeviceNetworkStatus.disconnected:
      markerColor = Colors.orange;
      break;
    case DeviceNetworkStatus.online:
      markerColor = Colors.green;
      break;
    case DeviceNetworkStatus.unknown:
      markerColor = Colors.grey;
      break;
    case DeviceNetworkStatus.offline:
      markerColor = Colors.blue;
  }
  if (device.isFollowed) {
    markerIcon = Icons.edit_location;
  }
  return Marker(
      anchorPos: AnchorPos.align(AnchorAlign.top),
      width: 60.0,
      height: 56.0,
      point: device.position.point,
      builder: (BuildContext context) {
        if (markerGestureDetectorBuilder != null) {
          return markerGestureDetectorBuilder(
              context,
              device,
              Column(
                children: <Widget>[
                  Text(device.name, textScaleFactor: 1.3),
                  Icon(markerIcon, size: 35.0, color: markerColor),
                ],
              ));
        }
        return _defaultGestureDetector(device, markerColor, markerIcon);
      });
}

GestureDetector _defaultGestureDetector(
        Device device, Color markerColor, IconData markerIcon) =>
    GestureDetector(
      child: Column(
        children: <Widget>[
          Text("${device.name}", textScaleFactor: 1.3),
          Icon(markerIcon, size: 35.0, color: markerColor),
          //if (<dynamic>[DeviceNetworkStatus.offline, null].contains(dns))
          //  Chip(label: Text("${timeago.format(device.lastPosition)}"))
        ],
      ),
      onTap: () {
        /*if (appState.flashIsPoped) {
              updateState(type: UpdateType.unpopDeviceInfo, value: null);
            }
            showDeviceInfo(context, device);
            updateState(type: UpdateType.popDeviceInfo, value: null);*/
      },
      onDoubleTap: () {
        //appState.map.centerOnPoint(device.position.point);
        //final bounds = LatLngBounds()..extend(device.position.point);
        //appState.map.mapController.fitBounds(bounds);

        //updateState(type: UpdateType.toggleDeviceBar, value: device);
      },
      //onLongPress: () => showDeviceOptions(context, device),
      onLongPress: () {
        //updateState(type: UpdateType.toggleDeviceVisibility, value: device);
      },
    );
