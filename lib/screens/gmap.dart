import 'dart:async';
import 'dart:math';
import 'package:burger_review_3/constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:fluster/fluster.dart';
import 'package:burger_review_3/map_marker.dart';
import 'package:burger_review_3/map_helper.dart';
import 'package:burger_review_3/restaurant_item_map.dart';

class Gmap extends StatefulWidget {
  //stless creates a new stateless widget easily

  @override
  State<Gmap> createState() => _GmapState();
}

class _GmapState extends State<Gmap>{

  final _googleMapsKey = GlobalKey();
  final Completer<GoogleMapController> _mapController = Completer();
  late NavigatorState _navigator;

  /// Set of displayed markers and cluster markers on the map
  final Set<Marker> _markers = Set();

  /// Minimum zoom at which the markers will cluster
  final int _minClusterZoom = 0;

  /// Maximum zoom at which the markers will cluster
  final int _maxClusterZoom = 20;

  /// [Fluster] instance used to manage the clusters
  Fluster<MapMarker>? _clusterManager;

  /// Current map zoom. Initial zoom will be 15, street level
  double _currentZoom = 15;

  /// Map loading flag
  bool _isMapLoading = true;

  /// Markers loading flag
  bool _areMarkersLoading = true;

  /// Markers JSON
  late List _json = [];

  /// Sorted markers JSON
  late List _jsonSorted = [];

  /// Color of the cluster circle
  final Color _clusterColor = kPrimaryColorLighter;

  /// Color of the cluster text
  final Color _clusterTextColor = Colors.white;

  /// Reload restaurants markers are loading bool
  var _rRMarkersLoading = false;

  var _kCameraPosition =
      const CameraPosition(target: LatLng(37.0902, -95.7129), zoom: 3.3);

  /// Radius from zoom
  var _radius = 8000;

  //List<Place> items = [Place(id: '17584', latLng: LatLng(34.44,-119.71)),Place(id: '17584', latLng: LatLng(34.44,-118.71)),Place(id: '17584', latLng: LatLng(34,-119.71))];

  void _onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);
    repositionMapToLocation(controller);

    if (mounted) {
      setState(() {
        _isMapLoading = false;
      });
    }

    //_initMarkers();
  }

  // void _initMarkers() async {
  //   final List<MapMarker> markers = [];
  //   List mapMarkersList = await getListOfMarkers();
  //   for (int i = 0; i < mapMarkersList.length; i++) {
  //     //final BitmapDescriptor markerImage =
  //     //await MapHelper.getMarkerImageFromUrl(_markerImageUrl);
  //     if (mapMarkersList.length > 0) {
  //       //print('adding markers');
  //       markers.add(mapMarkersList[i]);
  //     } else {
  //       print('no markers to display check 2');
  //     }
  //   }
  //
  //   _clusterManager = await MapHelper.initClusterManager(
  //     markers,
  //     _minClusterZoom,
  //     _maxClusterZoom,
  //   );
  //
  //   //await _updateMarkers();
  // }

  Future<void> _updateMarkers([double? updatedZoom]) async {
    // print('in update markers');
    //if (updatedZoom == _currentZoom) return;//_clusterManager == null ||
    //print('in update markers 2');
    //print("called _updateMarkers");

    if (updatedZoom != null) {
      _currentZoom = updatedZoom;
    }
    //print('current zoom $_currentZoom');

    final List<MapMarker> markers = [];

    if (_currentZoom >= 10) {
      List mapMarkersList = await getListOfMarkers();

      for (int i = 0; i < mapMarkersList.length; i++) {
        //final BitmapDescriptor markerImage = await MapHelper.getMarkerImageFromUrl('https://www.freeiconspng.com/thumbs/hamburgers-icon-png/hamburger-icon-stock-vector-2.jpg');
        markers.add(mapMarkersList[i]);
      }
    }

    _clusterManager = await MapHelper.initClusterManager(
      markers,
      _minClusterZoom,
      _maxClusterZoom,
    );

    await updateClusters();
    if(mounted) {
      setState(() {
        _areMarkersLoading = false;
      });
    }
  }

  Future updateClusters() async {
    final updatedMarkers = await MapHelper.getClusterMarkers(
      _clusterManager,
      _currentZoom,
      _clusterColor,
      _clusterTextColor,
      90,
    );

    _markers
      ..clear()
      ..addAll(updatedMarkers);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _navigator = Navigator.of(context);
    super.didChangeDependencies();
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   _navigator.pushAndRemoveUntil(..., (route) => ...);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    //print('in google maps page');
    Size _size = MediaQuery.of(context).size;
    return Column(
      children: [
        Flexible(
          child: Stack(
            children: [
              GoogleMap(
                mapToolbarEnabled: true,
                zoomGesturesEnabled: true,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                zoomControlsEnabled: true,
                initialCameraPosition: _kCameraPosition,
                markers: _markers,
                onMapCreated: (controller) {
                  _onMapCreated(controller);
                },
                onCameraMove: (position) {
                  _kCameraPosition = position;
                  if(mounted) {
                    setState(() {
                      _currentZoom = position.zoom;
                    });
                  }
                  if(_currentZoom > 10){
                    updateClusters();
                  } else if(_markers.isNotEmpty){
                    if(mounted) {
                      setState(() {
                        _markers.clear();
                      });
                    }
                  }
                },
                onCameraIdle: () {


                  if (_currentZoom > 10) {
                    if(!_rRMarkersLoading){
                      reloadRestaurants();
                    }else{
                      print('markers are loading catch');
                    }
                    //await reloadThenUpdateMap();
                    //updateClusters();
                  }//else
                },
                //_updateMarkers(_kCameraPosition.zoom),
                key: _googleMapsKey,
                //padding: EdgeInsets.only(top: 95),
              ),
              if (_currentZoom != null && _currentZoom < 10)
                Container(
                  padding: EdgeInsets.all(10),
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: const Text(
                        'Zoom in to see results',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ),
                  alignment: Alignment.topCenter,
                ),
              //Align(alignment: Alignment.bottomCenter, child: Container(color: Colors.red,height: 100,width: _size.width,padding: EdgeInsets.only(bottom: 0),)),
            ],
          ),
        ),
        if (_currentZoom > 10)
          Container(
            color: kBackgroundColorDarker,
            alignment: Alignment.bottomCenter,
            height: 100,
            width: MediaQuery.of(context).size.width,
            child: _areMarkersLoading
                ?
                //print('snapshot: $snapshot');
                Container(
                    child: const CircularProgressIndicator(),
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 25),
                  )
                : SizedBox(
                    //alignment: Alignment.topCenter,
                    height: 100,
                    child: ListView(
                      dragStartBehavior: DragStartBehavior.start,
                      scrollDirection: Axis.horizontal,
                      children: _jsonSorted.map<Widget>((json) {
                        final business = RestaurantForMap(json);
                        return MapRestaurantItem(business);
                      }).toList(),
                    ),
                  ),

            //print(snapshot.error);
            // return const Text('Internal Error',
            //     style: TextStyle(color: Colors.black));
          ),
      ],
    );
  }

  Future<List> reloadRestaurants() async {
    _radius = getRadiusFromZoom();
    print(_radius);
    _rRMarkersLoading = true;
    if(mounted){
      setState(() {
        _areMarkersLoading = true;
      });
    }
    if (_radius > 4000) {
      _json = await fetchBusinessSearch(
          latitude: _kCameraPosition.target.latitude,
          longitude: _kCameraPosition.target.longitude,
          categories: 'burgers');
    } else {
      _json = await fetchBusinessSearch(
          latitude: _kCameraPosition.target.latitude,
          longitude: _kCameraPosition.target.longitude,
          categories: 'burgers',
          radius: _radius);
    }
    await _updateMarkers(_kCameraPosition.zoom);

    _jsonSorted = _json;

    _jsonSorted.sort((a, b) {
      return a['distance'].toDouble().compareTo(b['distance'].toDouble());
    });
    _rRMarkersLoading = false;
    return _json;
  }

  Future repositionMapToLocation(GoogleMapController controller) async {
    print('at start of reposition map');
    Location location = Location();
    LocationData locationData;

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    print('in middle start of reposition');

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    print('in middle middle of reposition');
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    print('in middle end of reposition');

    locationData = await location.getLocation();
    print('got location');
    CameraPosition cameraPosition = new CameraPosition(
        target: LatLng(locationData.latitude!, locationData.longitude!),
        zoom: 13.5);
    print('at end of reposition map');
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    _kCameraPosition = cameraPosition;
    reloadRestaurants();
  } // move map to my current location

  Future<List> getListOfMarkers() async {
    List<MapMarker> m = [];
    //List l;
    final BitmapDescriptor markerImage =
        //BitmapDescriptor.defaultMarkerWithHue(1);
    await MapHelper.getMarker(105);

    // if (_radius < 4000) {
    //   _json = await fetchBusinessSearch(
    //       latitude: _kCameraPosition.target.latitude,
    //       longitude: _kCameraPosition.target.longitude,
    //       categories: 'burgers',
    //       radius: _radius);
    //   // print(l);
    // } else {
    //   _json = await fetchBusinessSearch(
    //       latitude: _kCameraPosition.target.latitude,
    //       longitude: _kCameraPosition.target.longitude,
    //       categories: 'burgers');
    //   //print('too far out zoom but still printing close up markers');
    //   // print(l);
    // }
    for (int i = 0; i < _json.length; i++) {
      //print('id: ${l[i]['id'].toString()}');
      m.add(
        MapMarker(
          id: _json[i]['id'].toString(),
          position: LatLng(_json[i]['coordinates']['latitude'].toDouble(),
              _json[i]['coordinates']['longitude'].toDouble()),
          icon: markerImage,
        ),
      );
    }

    return m;
  } //calls fetchbuisnesssearch to get list of markers

  int getRadiusFromZoom() {
    var zoom = _currentZoom;
    if (zoom > 16) {
      zoom = 16;
    }
    //print('zoom is $zoom');
    var r = (156543.03392 *
        cos(_kCameraPosition.target.latitude * pi / 180) ~/
        pow(2, zoom) *
        _googleMapsKey.currentContext!.size!.width.toInt());
    return r;
  }
}

class MyContainer extends Container {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
    );
  }
}
