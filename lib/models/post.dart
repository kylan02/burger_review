import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final datePublished;
  final String postUrl;
  final bool isVideo;
  final String profImage;
  final String vidThumbnail;
  final String restaurantId;
  final String restaurantName;
  final double restaurantScore;
  final likes;

  const Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.isVideo,
    required this.profImage,
    required this.vidThumbnail,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantScore,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'uid': uid,
    'username': username,
    'postId': postId,
    'datePublished': datePublished,
    'profImage': profImage,
    'likes': likes,
    'postUrl': postUrl,
    'vidThumbnail': vidThumbnail,
    'restaurantId': restaurantId,
    'restaurantName': restaurantName,
    'restaurantScore': restaurantScore,
    'isVideo': isVideo,
  };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      username: snapshot['username'],
      uid: snapshot['uid'],
      description: snapshot['description'],
      postId: snapshot['postId'],
      datePublished: snapshot['datePublished'],
      profImage: snapshot['smallProfImage'],
      likes: snapshot['likes'],
      postUrl: snapshot['postUrl'],
      vidThumbnail: snapshot['vidThumbnail'],
      restaurantId: snapshot['restaurantId'],
      restaurantName: snapshot['restaurantName'],
      restaurantScore: snapshot['restaurantScore'],
      isVideo: snapshot['isVideo'],
    );
  }
}