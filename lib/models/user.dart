
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String smallPhotoUrl;
  final String username;
  final String bio;
  final bool hasProfilePic;
  final List followers;
  final List following;

  const User({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.smallPhotoUrl,
    required this.username,
    required this.bio,
    required this.hasProfilePic,
    required this.followers,
    required this.following,
});

  Map<String, dynamic> toJson() => {
    'username': username,
    'uid': uid,
    'email': email,
    'bio': bio,
    'followers': [],
    'following': [],
    'hasProfilePic': hasProfilePic,
    'photoUrl': photoUrl,
    'smallPhotoUrl': smallPhotoUrl,
  };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot['username'],
      uid: snapshot['uid'],
      email: snapshot['email'],
      photoUrl: snapshot['photoUrl'],
      smallPhotoUrl: snapshot['smallPhotoUrl'],
      bio: snapshot['bio'],
      hasProfilePic: snapshot['hasProfilePic'],
      followers: snapshot['followers'],
      following: snapshot['following'],
    );
  }
}