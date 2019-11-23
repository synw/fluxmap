import 'dart:async';

import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluxmap/src/state.dart';
import 'package:fluxmap/src/types.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'store.dart';

class _FluxMapWidgetState extends State<FluxMapWidget> {
  _FluxMapWidgetState(
      {@required this.devicesFlux, this.center, this.zoom = 2.0}) {
    center ??= LatLng(0.0, 0.0);
  }

  final Stream<Device> devicesFlux;
  LatLng center;
  final double zoom;

  StreamSubscription<Device> _sub;
  StreamSubscription<MapPosition> _ms;
  bool _updateLoopStarted = false;
  Timer t;
  final _saveMapStateSignal = PublishSubject<MapPosition>();

  Future<void> _listenToFlux() async => _sub = devicesFlux.listen((device) {
        updateFluxMapState(
            type: FluxMapUpdateType.devicePosition, value: device);
      });

  Future<void> _startDeviceLoop() async {
    if (!_updateLoopStarted) {
      t = Timer.periodic(
          const Duration(seconds: 3),
          (t) => updateFluxMapState(
              type: FluxMapUpdateType.devicesStatus, value: null));
      _updateLoopStarted = true;
    }
  }

  @override
  void initState() {
    super.initState();
    print("MAP STATE ${fluxMapState.map}");
    fluxMapState.map.onReady.then((_) {
      _ms = _saveMapStateSignal
          .debounceTime(const Duration(milliseconds: 200))
          .listen((ms) {
        fluxMapState.center = ms.center;
        fluxMapState.zoom = ms.zoom;
      });
      print("MAP STATE READY");
      _listenToFlux();
      _startDeviceLoop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FluxMapStore>(context).state;
    //print("MAP ${state.map} / ${state.map.center}");
    return FlutterMap(
      mapController: state.map.mapController,
      options: MapOptions(
          center: state?.center ?? center,
          zoom: state?.zoom ?? zoom,
          onPositionChanged: (position, hasGesture) {
            //print("POS CHANGE $position / $hasGesture");
            //print("BOUNDS: ${state.map.center}/${state.map.zoom}");
            _saveMapStateSignal.sink
                .add(MapPosition(center: position.center, zoom: position.zoom));
          }),
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        PolygonLayerOptions(polygons: state.map.polygons),
        PolylineLayerOptions(polylines: state.map.lines),
        MarkerLayerOptions(markers: state.map.markers),
      ],
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    _ms.cancel();
    t.cancel();
    super.dispose();
  }
}

class FluxMapWidget extends StatefulWidget {
  const FluxMapWidget({@required this.devicesFlux, this.center, this.zoom});

  final Stream<Device> devicesFlux;
  final LatLng center;
  final double zoom;

  @override
  _FluxMapWidgetState createState() =>
      _FluxMapWidgetState(devicesFlux: devicesFlux, center: center, zoom: zoom);
}

class FluxMap extends StatefulWidget {
  const FluxMap(
      {@required this.devicesFlux,
      @required this.state,
      this.center,
      this.zoom = 2.0});

  final Stream<Device> devicesFlux;
  final FluxMapState state;
  final LatLng center;
  final double zoom;

  @override
  _FluxMapState createState() => _FluxMapState(
      devicesFlux: devicesFlux, state: state, center: center, zoom: zoom);
}

class _FluxMapState extends State<FluxMap> {
  _FluxMapState(
      {@required this.devicesFlux,
      @required this.state,
      this.center,
      this.zoom}) {
    fluxMapState = state;
  }

  final Stream<Device> devicesFlux;
  final FluxMapState state;
  final LatLng center;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    return StreamProvider<FluxMapStore>.value(
        initialData: FluxMapStore(),
        value: fluxMapStoreController.stream,
        child: FluxMapWidget(
          devicesFlux: devicesFlux,
          center: center,
          zoom: zoom,
        ));
  }
}
