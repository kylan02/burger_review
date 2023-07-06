import 'dart:io';
import 'dart:typed_data';

import 'package:burger_review_3/models/post.dart';
import 'package:burger_review_3/resources/storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ///upload post
  Future<String> uploadImagePost(
    String description,
    Uint8List imageFile,
    String uid,
    String username,
    String profImage,
    String restaurantId,
    String restaurantName,
    double restaurantScore,
  ) async {
    String res = "some error occurred";
    try {
      String photoUrl = await StorageMethods()
          .uploadImageToStorage('picturePosts', imageFile, true);
      String postId = const Uuid().v1();
      Post post = Post(
          description: description,
          uid: uid,
          username: username,
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: photoUrl,
          isVideo: false,
          vidThumbnail: '',
          profImage: profImage,
          restaurantId: restaurantId,
          restaurantName: restaurantName,
          restaurantScore: restaurantScore,
          likes: []);
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadVideoPost(
    String description,
    File videoFile,
    String uid,
    String username,
    String profImage,
    String restaurantId,
    String restaurantName,
    double restaurantScore,
  ) async {
    String res = "some error occurred";

    try {
      Uint8List? thumbnailPic;
      String videoUrl = 'no video';
      String thumbnailUrl = 'no thumbnail';
      var compressedVideo = await VideoCompress.compressVideo(videoFile.path);
      if (compressedVideo!.file != null) {
        videoUrl = await StorageMethods()
            .uploadVideoToStorage('videoPosts', compressedVideo.file!, true);

        ///upload video
        thumbnailPic =
            await VideoCompress.getByteThumbnail(compressedVideo.path!,
                quality: 80, // default(100)
                position: -1 // default(-1)
                );
      }

      if (thumbnailPic != null) {
        thumbnailUrl = await StorageMethods()
            .uploadImageToStorage('vidThumbnailPosts', thumbnailPic, true);

        ///upload thumbnail
      }

      String postId = const Uuid().v1();
      Post post = Post(
          description: description,
          uid: uid,
          username: username,
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: videoUrl,
          isVideo: true,
          vidThumbnail: thumbnailUrl,
          profImage: profImage,
          restaurantId: restaurantId,
          restaurantName: restaurantName,
          restaurantScore: restaurantScore,
          likes: []);
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(
      String postId, String uid, List likes, bool canDislike) async {
    try {
      if (!likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      } else if (canDislike == true && likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      }
    } catch (err) {
      print(
        err.toString(),
      );
    }
  }

  Future<void> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    try {
      if(text.isNotEmpty){
        String commentId = const Uuid().v1();
        await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
      } else{
        print('text is empty');
      }
    } catch (err) {
      print(err.toString());
    }
  }

  /// deleting post

  Future deletePost(String postId) async{
    try{
      await _firestore.collection('posts').doc(postId).delete();
    }catch(err){
      print(err.toString());
    }
  }
}
