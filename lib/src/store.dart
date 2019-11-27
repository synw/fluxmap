import 'dart:async';

import 'package:device/device.dart';
import 'package:flutter/foundation.dart';

import 'state.dart';
import 'types.dart';

/// The map state
///
/// Use this when you need to access the map state
/// without a context object
FluxMapState fluxMapState;

/// The updates store controller
final StreamController<FluxMapStore> fluxMapStoreController =
    StreamController<FluxMapStore>.broadcast();

/// Update the map state
void updateFluxMapState(
    {@required FluxMapUpdateType type, @required dynamic value}) {
  //print("MAP STATE UPDATE $type $value");
  fluxMapStoreController.sink.add(FluxMapStore.update(type, value));
}

/// The updates store
class FluxMapStore {
  /// Default contructor
  FluxMapStore() : state = fluxMapState;

  /// The state of the map
  final FluxMapState state;

  /// Update the state reducer
  FluxMapStore.update(FluxMapUpdateType type, dynamic value)
      : state = fluxMapState {
    switch (type) {
      case FluxMapUpdateType.devicePosition:
        assert(value != null);
        final v = value as Device;
        assert(v.position != null);
        state.updateDevicePosition(v);
        break;
      case FluxMapUpdateType.devicesStatus:
        state.checkDevicesStatus();
    }
  }
}
