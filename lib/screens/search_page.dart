import 'dart:convert';
import 'dart:io';

import 'package:burger_review_3/constants.dart';
import 'package:burger_review_3/restaurant_item.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:location/location.dart';
import 'package:burger_review_3/restaurant_item.dart';

class SearchPage extends StatefulWidget {
  //var token = 'BDPJIO0w-9bcLeiBYjS81TqtiWLAzF1JosVCrUPTVphm0hLyQ2-hoU8xgWpth4pTklAG8-6OKUkN19yx_m0elE_oqyBRUN55S02Jb0R39En0-Dca6qdXv2bjM7nbYXYx';
  // final api = Dio(
  //   BaseOptions(baseUrl: 'https://api.yelp.com/v3/businesses/search', headers: {
  //     'Authorization':
  //         'Bearer BDPJIO0w-9bcLeiBYjS81TqtiWLAzF1JosVCrUPTVphm0hLyQ2-hoU8xgWpth4pTklAG8-6OKUkN19yx_m0elE_oqyBRUN55S02Jb0R39En0-Dca6qdXv2bjM7nbYXYx',
  //     "Content-type": "application/json",
  //   }),
  // );

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // var _headers = {
  //   'Authorization':
  //       'Bearer BDPJIO0w-9bcLeiBYjS81TqtiWLAzF1JosVCrUPTVphm0hLyQ2-hoU8xgWpth4pTklAG8-6OKUkN19yx_m0elE_oqyBRUN55S02Jb0R39En0-Dca6qdXv2bjM7nbYXYx',
  //   "Content-type": "application/json",
  // };
  var _search;
  var location;
  final fieldText = TextEditingController();
  var nearMeIsSelected = true;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        // The search area here
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: TextField(
              controller: fieldText,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    /* Clear the search field */
                    fieldText.clear();
                  },
                ),
                hintText: 'Search...',
                border: InputBorder.none,
                iconColor: Colors.grey,
              ),
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.grey,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (value) {
                setState(() {
                  _search = value;
                });
                //searchResturaunts(value);
                //fetchAutocomplete(text: value, latitude: 34, longitude: 119);
                // if (location != null) {
                //   fetchBusinessSearch(
                //       term: value,
                //       categories: 'burgers',
                //       radius: 40000,
                //       latitude: location.latitude,
                //       longitude: location.longitude);
                // } else {
                //   fetchBusinessSearch(
                //       term: value,
                //       categories: 'burgers',
                //       radius: 40000,
                //       location: 'NYC');
                // }
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: kPrimaryColor,
            child: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        child: InkWell(
                          child: const Center(
                              child: Text(
                            'Near Me',
                            style: TextStyle(color: Colors.white),
                          )),
                          onTap: () {
                            setState(() {
                              nearMeIsSelected = true;
                            });
                          },
                        ),
                        //color: nearMeIsSelected ? kHighlightColor : kPrimaryColor,
                        decoration: BoxDecoration(
                          color: nearMeIsSelected ? kHighlightColor : kPrimaryColor,
                          boxShadow: [
                            nearMeIsSelected ? BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              spreadRadius: 0,
                              blurRadius: 3,
                              offset: const Offset(0, 0), // changes position of shadow
                            )
                                : const BoxShadow(),
                          ],
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        child: InkWell(
                          child: const Center(
                            child: Text(
                              'United States',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              nearMeIsSelected = false;
                            });
                          },
                        ),
                        //color: !nearMeIsSelected ? kHighlightColor : kPrimaryColor,
                        decoration: BoxDecoration(
                          color: !nearMeIsSelected ? kHighlightColor : kPrimaryColor,
                          boxShadow: [
                            !nearMeIsSelected ? BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              spreadRadius: 0,
                              blurRadius: 3,
                              offset: const Offset(0, 0), // changes position of shadow
                            )
                                : const BoxShadow(),
                          ],
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            width: double.infinity,
            height: 30,
          ),
          Expanded(
            child: _search != null
                ? FutureBuilder(
                    future: location != null && nearMeIsSelected
                        ? fetchBusinessSearch(
                            term: _search,
                            latitude: location.latitude,
                            longitude: location.longitude,
                            categories: 'burgers')
                        : fetchBusinessSearch(
                            term: _search,
                            location: 'United States',
                            //locale: 'en_US',
                            categories: 'burgers'),
                    builder: (context, AsyncSnapshot<List> snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasData) {
                        return ListView(
                          children: snapshot.data!.map<Widget>((json) {
                            final business = Restaurant(json);
                            return RestaurantItem(business);
                          }).toList(),
                        );
                      }
                      print(snapshot.error);
                      return Text('Internal Error');
                    },
                  )
                : const Text(''),
            // child: _resturaunts != null
            //     ? ListView(
            //       children: _resturaunts.map<Widget>((business) {
            //         return ListTile(
            //           title: Text(business['name'], style: TextStyle(color: Colors.black),),
            //           subtitle: Text(business['location']['address1'], style: TextStyle(color: Colors.black),),
            //           trailing: Text('${business['rating']} stars', style: TextStyle(color: Colors.black),),
            //         );
            //       }).toList(),
            //     )
            //     : Text(
            //         '',
            //         style: TextStyle(color: Colors.black, fontSize: 30),
            //       ),
          ),
        ],
      ),
    );
  }

  void getLocation() async {
    Location loc = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await loc.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await loc.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await loc.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await loc.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await loc.getLocation();
    setState(() {
      location = _locationData;
    });
  }
}
