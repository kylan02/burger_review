import 'dart:typed_data';

import 'package:burger_review_3/resources/storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:burger_review_3/resources/storage_methods.dart';
import 'package:burger_review_3/models/user.dart' as model;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap = await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  /// sign up user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    Uint8List? file,
    Uint8List? smallProfImage,
  }) async {
    String res = "Some error occurred";
    Uint8List _finalSmallProfImage;
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty /*|| file != null*/) {
        ///register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        print(cred.user!.uid);

        String photoUrl;
        String smallProfilePicUrl;
        bool hasProfilePic;
        if (file != null && smallProfImage != null) {
          _finalSmallProfImage = await FlutterImageCompress.compressWithList(smallProfImage, quality: 1);
          smallProfilePicUrl = await StorageMethods()
              .uploadImageToStorage('smallProfilePics', _finalSmallProfImage, false);

          photoUrl = await StorageMethods()
              .uploadImageToStorage('profilePics', file, false);
          hasProfilePic = true;
        } else {
          photoUrl = 'noProfilePic';
          smallProfilePicUrl = 'noSmallProfilePic';
          hasProfilePic = false;
        }

        ///add user to our database
        ///
        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          email: email,
          bio: bio,
          hasProfilePic: hasProfilePic,
          photoUrl: photoUrl,
          smallPhotoUrl: smallProfilePicUrl,
          following: [],
          followers: [],
        );

        _firestore.collection('users').doc(cred.user!.uid).set(user.toJson());
        res = 'success';
      } else {
        res = 'Please enter all the fields';
      }
    }
    // on FirebaseAuthException catch(err){
    //   if(err.code == 'invalid-email'){
    //     res = 'The email is badly formatted';
    //   }else if(err.code == 'weak-password'){
    //     res = 'Password should be at least 6 characters';
    //   }
    // }

    catch (err) {
      res = err.toString();
    }
    return res;
  }

  ///Logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'success';
      } else {
        res = 'Please enter all the fields';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
