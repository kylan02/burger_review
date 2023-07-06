import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:burger_review_3/main.dart';
import 'package:flutter/material.dart';

//colors for app
const kPrimaryColor = Color(0xff152238);//Color(0xffA8713A); //0xff is for hex color
const kPrimaryColorLighter = Color(0xff5b6474);
const kTextColor = Colors.white;
const kBackgroundColor = Color(0xffeff0f1);//Color(0xfff8f2ec);
const kBackgroundColorDarker = Color(0xffe8e9eb);//Color(0xfff5ede5);
const kHighlightColor = Color(0xff3236b4);//3236b4

const double kDefaultPadding = 20;

///only non const
String positionInStack = '';

Future<List> fetchBusinessSearch(
    {String? term,
      String? location,
      double? latitude,
      double? longitude,
      int? radius,
      String? categories,
      String? locale,
      int? limit,
      int? offset,
      String? sortBy,
      String? price,
      bool? openNow,
      int? openAt,
      String? attributes,
      bool asObject = true}) async {
  assert(latitude != null && longitude != null || location != null);

  final _headers = {
    'Authorization':
    'Bearer BDPJIO0w-9bcLeiBYjS81TqtiWLAzF1JosVCrUPTVphm0hLyQ2-hoU8xgWpth4pTklAG8-6OKUkN19yx_m0elE_oqyBRUN55S02Jb0R39En0-Dca6qdXv2bjM7nbYXYx',
    "Content-type": "application/json",
  };

  print("calling Yelp API");

  var params = {
    if (term != null) 'term': term,
    if (location != null) 'location': location,
    if (latitude != null) 'latitude': latitude.toString(),
    if (longitude != null) 'longitude': longitude.toString(),
    if (radius != null) 'radius': radius.toString(),
    if (categories != null) 'categories': categories,
    if (locale != null) 'locale': locale,
    if (limit != null) 'limit': limit.toString(),
    if (offset != null) 'offset': offset.toString(),
    if (sortBy != null) 'sort_by': sortBy,
    if (price != null) 'price': price,
    if (openNow != null) 'open_now': openNow.toString(),
    if (openAt != null) 'open_at': openAt.toString(),
    if (attributes != null) 'attributes': attributes,
  };

  var url = Uri.https('api.yelp.com', 'v3/businesses/search', params);

  final response = await http.get(url, headers: _headers);

  Map<String, dynamic> jsonData = Map<String, dynamic>.from(json.decode(response.body));

  if (jsonData.containsKey('error')) {
    print('error: ' + jsonData['error'].toString());
    return jsonData['error'];
  } else {
    //print('business search:' + jsonData.toString());
    return jsonData['businesses'];

    //return jsonData;
  }
  // setState(() {
  //   _resturaunts = jsonData;
  // });
}

Future fetchIndividualBusiness(String id) async {

  final _headers = {
    'Authorization':
    'Bearer BDPJIO0w-9bcLeiBYjS81TqtiWLAzF1JosVCrUPTVphm0hLyQ2-hoU8xgWpth4pTklAG8-6OKUkN19yx_m0elE_oqyBRUN55S02Jb0R39En0-Dca6qdXv2bjM7nbYXYx',
    "Content-type": "application/json",
  };

  print("calling Yelp API individual business");

  var params = {'': id,};

  var url = Uri.https('api.yelp.com', 'v3/businesses/$id');

  print('Url: $url');

  final response = await http.get(url, headers: _headers);

  Map<String, dynamic> jsonData = json.decode(response.body);

  if (jsonData.containsKey('error')) {
    print('error: ' + jsonData['error'].toString());
    return jsonData['error'];
  } else {
    print('business search:' + jsonData.toString());
    return jsonData;
    ///Test ID: tm87DWqehpt79ZInFVmv1w
    //return jsonData;
  }
  // setState(() {
  //   _resturaunts = jsonData;
  // });
}