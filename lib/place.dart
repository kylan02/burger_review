import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';

class Place with ClusterItem {
  final String id;
  final bool isClosed;
  final LatLng latLng;

  Place({required this.id, required this.latLng, this.isClosed = false});

  @override
  String toString() {
    return 'Place $id (closed : $isClosed)';
  }

  @override
  LatLng get location => latLng;
}