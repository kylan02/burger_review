import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:burger_review_3/map_marker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// In here we are encapsulating all the logic required to get marker icons from url images
/// and to show clusters using the [Fluster] package.
class MapHelper {
  /// If there is a cached file and it's not old returns the cached marker image file
  /// else it will download the image and save it on the temp dir and return that file.
  ///
  /// This mechanism is possible using the [DefaultCacheManager] package and is useful
  /// to improve load times on the next map loads, the first time will always take more
  /// time to download the file and set the marker image.
  ///
  /// You can resize the marker image by providing a [targetWidth].

  /// Draw a [clusterColor] circle with the [clusterSize] text inside that is [width] wide.
  ///
  /// Then it will convert the canvas to an image and generate the [BitmapDescriptor]
  /// to be used on the cluster marker icons.
  ///

  static Future<BitmapDescriptor> getMarkerImageFromUrl(
      String url, {
        int? targetWidth,
      }) async {
    final File markerImageFile = await DefaultCacheManager().getSingleFile(url);
    Uint8List markerImageBytes = await markerImageFile.readAsBytes();
    if (targetWidth != null) {
      markerImageBytes = await _resizeImageBytes(
        markerImageBytes,
        targetWidth,
      );
    }
    return BitmapDescriptor.fromBytes(markerImageBytes);
  }

  static Future<BitmapDescriptor> getMarker(
      int width,
      ) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint();

    final double radius = width / 2;

    // canvas.drawCircle(
    //   Offset(radius, radius),
    //   radius,
    //   paint,
    // );
    var _blueCircle = await loadImageAsset('assets/Icons/pin2.png', (width*0.65).toInt());
    canvas.drawImage(_blueCircle, Offset.zero, paint);

    // var _burger = await loadImageAsset('assets/Icons/burger2.png', width);
    // canvas.drawImage(_burger, Offset.zero, paint);

    final image = await pictureRecorder.endRecording().toImage(
      radius.toInt() * 2,
      radius.toInt() * 2,
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
  static Future<ui.Image> loadImageAsset(String assetName, int width) async {
    final data = await rootBundle.load(assetName);
    var _resized = await _resizeImageBytes(data.buffer.asUint8List(), width);
    return decodeImageFromList(_resized);
  }

  static Future<BitmapDescriptor> _getClusterMarker(
      int clusterSize,
      Color clusterColor,
      Color textColor,
      int width,
      ) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = clusterColor;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final double radius = width / 2;

    // canvas.drawCircle(
    //   Offset(radius, radius),
    //   radius,
    //   paint,
    // );
    var _img = await loadImageAsset('assets/Icons/blueCircle.png', width);
    canvas.drawImage(_img, Offset.zero, paint);

    textPainter.text = TextSpan(
      text: clusterSize.toString(),
      style: TextStyle(
        fontSize: radius - 5,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
    );

    final image = await pictureRecorder.endRecording().toImage(
      radius.toInt() * 2,
      radius.toInt() * 2,
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  /// Resizes the given [imageBytes] with the [targetWidth].
  ///
  /// We don't want the marker image to be too big so we might need to resize the image.
  static Future<Uint8List> _resizeImageBytes(
      Uint8List imageBytes,
      int targetWidth,
      ) async {
    final ui.Codec imageCodec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: targetWidth,
    );

    final ui.FrameInfo frameInfo = await imageCodec.getNextFrame();

    final data = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

    return data!.buffer.asUint8List();
  }

  /// Inits the cluster manager with all the [MapMarker] to be displayed on the map.
  /// Here we're also setting up the cluster marker itself, also with an [clusterImageUrl].
  ///
  /// For more info about customizing your clustering logic check the [Fluster] constructor.
  static Future<Fluster<MapMarker>> initClusterManager(
      List<MapMarker> markers,
      int minZoom,
      int maxZoom,
      ) async {
    var _icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(64, 64)), 'assets/Icons/burger.png');
    return Fluster<MapMarker>(
      minZoom: minZoom,
      maxZoom: maxZoom,
      radius: 150,
      extent: 2048,
      nodeSize: 64,
      points: markers,
      createCluster: (
          BaseCluster? cluster,
          double? lng,
          double? lat,
          ) {

        return MapMarker(
            id: cluster!.id.toString(),
            position: LatLng(lat!, lng!),
            isCluster: cluster.isCluster,
            clusterId: cluster.id,
            pointsSize: cluster.pointsSize,
            childMarkerId: cluster.childMarkerId,
            //icon: _icon,
        );
      }

    );
  }

  /// Gets a list of markers and clusters that reside within the visible bounding box for
  /// the given [currentZoom]. For more info check [Fluster.clusters].
  static Future<List<Marker>> getClusterMarkers(
      Fluster<MapMarker>? clusterManager,
      double currentZoom,
      Color clusterColor,
      Color clusterTextColor,
      int clusterWidth,
      ) {
    if (clusterManager == null) return Future.value([]);

    return Future.wait(clusterManager.clusters(
      [-180, -85, 180, 85],
      currentZoom.toInt(),
    ).map((mapMarker) async {
      if (mapMarker.isCluster!) {
        mapMarker.icon = await _getClusterMarker(
          mapMarker.pointsSize!,
          clusterColor,
          clusterTextColor,
          clusterWidth,
        );
        //print('cluster');
      }

      return mapMarker.toMarker();
    }).toList());
  }
}