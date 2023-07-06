import 'dart:io';

import 'package:burger_review_3/resources/firestore_methods.dart';
import 'package:burger_review_3/providers/user_provider.dart';
import 'package:burger_review_3/screens/comments_screen.dart';
import 'package:burger_review_3/screens/profile_screen.dart';
import 'package:burger_review_3/screens/restaurant_info_page.dart';
import 'package:burger_review_3/utils.dart';
import 'package:burger_review_3/widgets/like_animation.dart';
import 'package:burger_review_3/widgets/video_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';

class PostCard extends StatefulWidget {
  final snap;

  const PostCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  bool pressedPlayOnVideo = false;
  int commentLen = 0;

  @override
  void initState() {
    super.initState();
    getComments();
  }

  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser!;
    bool isVideo = widget.snap['isVideo'];
    var _networkVideo = widget.snap['postUrl'];
    File file = File('');

    return Container(
      //color: Colors.amber,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                .copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    widget.snap['profImage'],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 4),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                                text: widget.snap['username'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = (() {
                                    // Navigator.of(context).push(
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         ProfileScreen(id: widget.snap['uid'],),
                                    //   ),
                                    // );
                                  })),
                            const TextSpan(
                              text: ' at ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text: widget.snap['restaurantName'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = (() {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RestaurantInfoPage(
                                          id: widget.snap['restaurantId'],
                                          name: widget.snap['restaurantName'],
                                        ),
                                      ),
                                    );
                                  })),
                          ],
                        ),
                      ),
                    ),

                    // Text(
                    //   '${widget.snap['username']} at ${widget.snap['restaurantName']}',
                    //   style: const TextStyle(
                    //       fontWeight: FontWeight.bold, color: Colors.black),
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => Dialog(
                              child: ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shrinkWrap: true,
                                children: [
                                  'Delete',
                                ]
                                    .map(
                                      (e) => InkWell(
                                        onTap: () async {
                                          FirestoreMethods().deletePost(
                                              widget.snap['postId']);
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Text(
                                            e,
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ));
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),

          ///Image/Video Section
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likePost(
                widget.snap['postId'],
                user.uid,
                widget.snap['likes'],
                false,
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            onTap: () async {
              if (isVideo) {
                if (!pressedPlayOnVideo) {
                  setState(() {
                    pressedPlayOnVideo = true;
                  });
                }
              }
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  pressedPlayOnVideo
                      ? VideoWidget(
                          file,
                          _networkVideo,
                          true,
                          MediaQuery.of(context).size.width,
                          MediaQuery.of(context).size.width)
                      : SizedBox(
                          height: MediaQuery.of(context).size.width,
                          width: MediaQuery.of(context).size.width,
                          child: isVideo //if post is a video
                              ? Image.network(
                                  widget.snap['vidThumbnail'],
                                  fit: BoxFit.cover,
                                )
                              //Icon(Icons.play_arrow, size: 50,)
                              : Image.network(
                                  widget.snap['postUrl'],
                                  fit: BoxFit.cover,
                                ),
                        ),
                  isVideo && !pressedPlayOnVideo
                      ? const Center(
                          child: Icon(
                            Icons.play_arrow,
                            size: 100,
                          ),
                        )
                      : Container(),
                  !isVideo
                      ? AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isLikeAnimating ? 1 : 0,
                          child: LikeAnimation(
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 100,
                            ),
                            isAnimating: isLikeAnimating,
                            duration: const Duration(milliseconds: 400),
                            onEnd: () {
                              setState(() {
                                isLikeAnimating = false;
                              });
                            },
                            smallLike: false,
                          ),
                        )
                      : Container(),
                  // Align(
                  //   child: Container(
                  //     width: 50,
                  //     height: 50,
                  //     child: Stack(
                  //       children: [
                  //         Container(
                  //           padding: const EdgeInsets.all(5),
                  //           child: Image.asset('assets/Icons/darkBlueCircle.png')
                  //         ),
                  //         Container(
                  //           padding: const EdgeInsets.all(5),
                  //           alignment: Alignment.center,
                  //           child: Text(
                  //             widget.snap['restaurantScore'].toString(),
                  //             style: const TextStyle(
                  //                 color: Colors.white,
                  //                 fontSize: 18,
                  //                 fontWeight: FontWeight.bold),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     //alignment: Alignment.center,
                  //   ),
                  //   alignment: Alignment.topLeft,
                  // ),
                ],
              ),
            ),
          ),

          ///Like and comment section
          Row(
            children: [
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user.uid),
                smallLike: true,
                child: IconButton(
                  onPressed: () async {
                    await FirestoreMethods().likePost(widget.snap['postId'],
                        user.uid, widget.snap['likes'], true);
                  },
                  icon: widget.snap['likes'].contains(user.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_border,
                          color: Colors.black,
                        ),
                ),
                duration: const Duration(milliseconds: 400),
                onEnd: () {},
              ),
              IconButton(
                onPressed: () => Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => CommentsScreen(
                      snap: widget.snap,
                    ),
                  ),
                )
                    .then((value) {
                  getComments();
                }),
                icon: const Icon(
                  Icons.comment_outlined,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.send,
                ),
              ),
              Expanded(
                child: Container(),
              ),
              //Text('Score: ', style: TextStyle(color: Colors.black),),
              Container(
                height: 40,
                width: 40,
                //alignment: Alignment.center,
                child: Stack(
                  children: [
                    Image.asset('assets/Icons/darkBlueCircle.png'),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.snap['restaurantScore'].toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              //Expanded(child: Container(),),
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          /// Description and Number of Comments
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.snap['likes'].length == 1
                    ? const Text('1 like',
                        style: TextStyle(color: Colors.black))
                    : Text(
                        '${widget.snap['likes'].length} likes',
                        style: const TextStyle(color: Colors.black),
                      ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 4),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: widget.snap['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ${widget.snap['description']}',
                          //style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        snap: widget.snap,
                      ),
                    ),
                  )
                      .then((value) {
                    getComments();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'View all ${commentLen} comments',
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd().format(
                      widget.snap['datePublished'].toDate(),
                    ),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
