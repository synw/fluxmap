import 'dart:async';

import 'package:device/device.dart';
import 'package:flutter/foundation.dart';

import 'state.dart';
import 'types.dart';

FluxMapState fluxMapState;

final StreamController<FluxMapStore> fluxMapStoreController =
    StreamController<FluxMapStore>.broadcast();

void updateFluxMapState(
    {@required FluxMapUpdateType type, @required dynamic value}) {
  //print("MAP STATE UPDATE $type $value");
  fluxMapStoreController.sink.add(FluxMapStore.update(type, value));
}

class FluxMapStore {
  FluxMapStore() : state = fluxMapState;

  final FluxMapState state;

  FluxMapStore.update(FluxMapUpdateType type, dynamic value)
      : state = fluxMapState {
    switch (type) {
      case FluxMapUpdateType.devicePosition:
        assert(value != null);
        final v = value as Device;
        assert(v.position != null);
        state.updateDevicePosition(v, verbose: true);
        break;
      case FluxMapUpdateType.devicesStatus:
        state.checkDevicesStatus();
    }
  }
}
