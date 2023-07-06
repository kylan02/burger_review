import 'package:burger_review_3/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/user_provider.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({Key? key}) : super(key: key);

  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  var filter = 1; //0 is 'for you page', 1 is recent, 2 is following

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: kPrimaryColor,
          child: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                // Expanded(
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 10),
                //     child: Container(
                //       child: InkWell(
                //         child: const Center(
                //             child: Text(
                //           'Featured',
                //           style: TextStyle(color: Colors.white),
                //         )),
                //         onTap: () {
                //           setState(() {
                //             filter = 0;
                //           });
                //         },
                //       ),
                //       //color: nearMeIsSelected ? kHighlightColor : kPrimaryColor,
                //       decoration: BoxDecoration(
                //         color: filter == 0 ? kHighlightColor : kPrimaryColor,
                //         boxShadow: [
                //           filter == 0
                //               ? BoxShadow(
                //                   color: Colors.black.withOpacity(0.5),
                //                   spreadRadius: 0,
                //                   blurRadius: 3,
                //                   offset: const Offset(
                //                       0, 0), // changes position of shadow
                //                 )
                //               : const BoxShadow(),
                //         ],
                //         borderRadius:
                //             const BorderRadius.all(Radius.circular(10)),
                //       ),
                //     ),
                //   ),
                // ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      child: InkWell(
                        child: const Center(
                          child: Text(
                            'Recent',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            filter = 1;
                          });
                        },
                      ),
                      //color: !nearMeIsSelected ? kHighlightColor : kPrimaryColor,
                      decoration: BoxDecoration(
                        color: filter == 1 ? kHighlightColor : kPrimaryColor,
                        boxShadow: [
                          filter == 1
                              ? BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 0,
                                  blurRadius: 3,
                                  offset: const Offset(
                                      0, 0), // changes position of shadow
                                )
                              : const BoxShadow(),
                        ],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                // Expanded(
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 10),
                //     child: Container(
                //       child: InkWell(
                //         child: const Center(
                //           child: Text(
                //             'Following',
                //             style: TextStyle(color: Colors.white),
                //           ),
                //         ),
                //         onTap: () {
                //           setState(() {
                //             filter = 2;
                //           });
                //         },
                //       ),
                //       //color: !nearMeIsSelected ? kHighlightColor : kPrimaryColor,
                //       decoration: BoxDecoration(
                //         color: filter == 2 ? kHighlightColor : kPrimaryColor,
                //         boxShadow: [
                //           filter == 2
                //               ? BoxShadow(
                //                   color: Colors.black.withOpacity(0.5),
                //                   spreadRadius: 0,
                //                   blurRadius: 3,
                //                   offset: const Offset(
                //                       0, 0), // changes position of shadow
                //                 )
                //               : const BoxShadow(),
                //         ],
                //         borderRadius:
                //             const BorderRadius.all(Radius.circular(10)),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          width: double.infinity,
          height: 30,
        ),
        Expanded(
          child: StreamBuilder(
            stream: //filter == 1
            //     ?
    FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('datePublished', descending: true)
                    .snapshots(),
                // : filter == 2
                //     ? FirebaseFirestore.instance
                //         .collection('posts')
                //         .orderBy('datePublished', descending: true)
                //         .snapshots()
                //     : FirebaseFirestore.instance
                //         .collection('posts')
                //         .orderBy('datePublished', descending: true)
                //         .snapshots(), //do .doc().snapshots to get individual posts for users
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  Provider.of<UserProvider>(context).getUser == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) =>
                    PostCard(snap: snapshot.data!.docs[index].data()),
              );
            },
          ),
        ),
      ],
    );
    //Container(child: Text('This will have social page...', style: TextStyle(color: Colors.black, fontSize: 18),));
  }
}
