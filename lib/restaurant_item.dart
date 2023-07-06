
import 'package:burger_review_3/constants.dart';
import 'package:burger_review_3/screens/restaurant_info_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RestaurantItem extends StatelessWidget {
  final Restaurant business;

  RestaurantItem(this.business);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        positionInStack = 'RestaurantInfoPage',
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => RestaurantInfoPage(id: business.id,name: business.name,))),
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              business.thumbnail != null && business.thumbnail.isNotEmpty
                  ? Ink(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(business.thumbnail),
                  ),
                ),
              )
                  : Container(
                height: 100,
                width: 100,
                color: Colors.blueGrey,
                child: Icon(
                  Icons.restaurant,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 10,),
                      Text(business.address, style: TextStyle(color: Colors.black),),
                      SizedBox(height: 10,),
                      Text(business.rating.toString(), style: TextStyle(color: Colors.black),),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // return ListTile(
    //   title: Text(
    //     business.name,
    //     style: TextStyle(color: Colors.black),
    //   ),
    //   subtitle: Text(
    //     business.address,
    //     style: TextStyle(color: Colors.black),
    //   ),
    //   trailing: Text(
    //     '${business.rating} stars',
    //     style: TextStyle(color: Colors.black),
    //   ),
    // );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String thumbnail;

  Restaurant._({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.thumbnail,
  });

  factory Restaurant(Map json) => Restaurant._(
      id: json['id'],
      name: json['name'],
      address: json['location']['address1'],
      rating: json['rating'],
      thumbnail: json['image_url']);
}
