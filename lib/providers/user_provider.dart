

import 'package:burger_review_3/models/user.dart';
import 'package:burger_review_3/resources/auth_methods.dart';
import 'package:flutter/cupertino.dart';

class UserProvider with ChangeNotifier{
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User? get getUser => _user;

  Future<void> refreshUser() async{
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners(); //this tells _user that the data has been changes so change it in the app
  }
}