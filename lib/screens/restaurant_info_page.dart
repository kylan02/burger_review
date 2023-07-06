import 'package:burger_review_3/screens/gmap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:burger_review_3/constants.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../post_card_small.dart';
import 'add_post_screen.dart';

class RestaurantInfoPage extends StatefulWidget {
  const RestaurantInfoPage({Key? key, required this.id, required this.name})
      : super(key: key);

  final String id;
  final String name;

  @override
  _RestaurantInfoPageState createState() => _RestaurantInfoPageState();
}

class _RestaurantInfoPageState extends State<RestaurantInfoPage> {
  var _amountOfReviews = 0;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //if (positionInStack == 'RestaurantInfoPage') {
    var size = MediaQuery.of(context).size;
    print('in restaurant_info page');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text('${widget.name}'),
      ),
      body: FutureBuilder(
        future: fetchIndividualBusiness(widget.id),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            Map<String, dynamic> _json = snapshot.data;
            List photos = _json['photos'];
            //List<Widget> photoObjects = [];

            // Container(
            //   //height: 260,
            //   width: size.width,
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       fit: BoxFit.fitWidth,
            //       //alignment: Alignment.center,
            //       image: NetworkImage('${photos[i]}'),
            //     ),
            //   ),
            // );
            //print('json: $_json');
            print(photos);
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      height: 230,
                      child: PhotoViewGallery.builder(
                        itemCount: photos.length,
                        builder: (context, index) {
                          final urlImage = photos[index];

                          return PhotoViewGalleryPageOptions(
                            imageProvider: NetworkImage(urlImage),
                            initialScale: PhotoViewComputedScale.covered,
                            disableGestures: true,
                          );
                        },
                        loadingBuilder: (context, event) => Center(
                          child: Container(
                            width: 20.0,
                            height: 20.0,
                            child: const CircularProgressIndicator(),
                          ),
                        ),
                        scrollDirection: Axis.horizontal,
                      )),
                  Container(
                    color: Colors.white,
                    width: size.width,
                    child: Stack(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Container(
                                child: Text(
                                  '${_json['name']}',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(
                                    left: 10, top: 10, bottom: 5),
                              ),
                              Container(
                                child: Text(
                                  '${_json['location']['address1']}, ${_json['location']['city']}, ${_json['location']['state']}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 10),
                              ),
                              Container(
                                child: Text(
                                  'Phone: ${_json['display_phone']}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 10),
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                          width: size.width - 50,
                        ),
                        // Flexible(
                        //   child: Container(),
                        //   flex: 2,
                        // ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                child: IconButton(
                                  icon: Icon(Icons.map_outlined),
                                  onPressed: elevatedButtonPressed,
                                  color: kPrimaryColor,
                                  iconSize: 30,
                                ),
                                padding: EdgeInsets.only(right: 10),
                              ),
                              Container(
                                child: IconButton(
                                  icon: Icon(Icons.call),
                                  onPressed: elevatedButtonPressed,
                                  color: kPrimaryColor,
                                  iconSize: 30,
                                ),
                                padding: EdgeInsets.only(right: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(bottom: 10),
                  ),
                  Container(
                    color: Colors.white,
                    width: size.width,
                    //height: 1000,
                    //padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .where('restaurantId', isEqualTo: widget.id)
                              .orderBy('datePublished', descending: true)
                              .limit(3)
                              .snapshots(), //do .doc().snapshots to get individual posts for users
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            // if (snapshot.connectionState ==
                            //     ConnectionState.waiting) {
                            // }
                            if (snapshot.hasData) {
                              _amountOfReviews = snapshot.data!.docs.length;
                              return Column(
                                children: [
                                  SizedBox(
                                    width: size.width,
                                    height: 5,
                                  ),
                                  Container(
                                    color: Colors.white,
                                    width: size.width,
                                    //padding: EdgeInsets.only(bottom: 10),
                                    child: Column(
                                      children: [
                                        Container(
                                          child: const Text(
                                            'Night Shift Score: 8.6',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          padding: EdgeInsets.only(top: 10),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: OutlinedButton(
                                            onPressed: () async{
                                              positionInStack = 'AddPostScreen';
                                              await Navigator.of(context)
                                                  .push(
                                                MaterialPageRoute(
                                                  builder: (_) => AddPostScreen(
                                                    name: '${_json['name']}',
                                                    id: widget.id,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: _amountOfReviews == 0
                                                ? const Text(
                                                    'Be the First to Leave a Review',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  )
                                                : const Text(
                                                    'Leave a Review',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        kPrimaryColor),
                                                minimumSize:
                                                    MaterialStateProperty.all(
                                                        Size(40, 40))),
                                          ),
                                          width: size.width / 1.2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width,
                                    height: 5,
                                  ),
                                  snapshot.data!.docs.isNotEmpty
                                      ? Column(
                                          children: [
                                            Container(
                                              child: const Text(
                                                'Night Shift Reviews:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              ),
                                              padding: EdgeInsets.all(10),
                                              alignment: Alignment.topLeft,
                                            ),
                                            Container(
                                              height: (100 *
                                                      snapshot
                                                          .data!.docs.length)
                                                  .toDouble(),
                                              color: Colors.grey[50],
                                              child: ListView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder: (context, index) =>
                                                    PostCardSmall(
                                                        snap: snapshot
                                                            .data!.docs[index]
                                                            .data()),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container()
                                ],
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          print(snapshot.error);
          return const Text('Internal Error');
        },
      ),
    );
  }

  void elevatedButtonPressed() {}
}
