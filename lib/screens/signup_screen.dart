import 'dart:typed_data';

import 'package:burger_review_3/constants.dart';
import 'package:burger_review_3/main.dart';
import 'package:burger_review_3/providers/user_provider.dart';
import 'package:burger_review_3/resources/auth_methods.dart';
import 'package:burger_review_3/text_field_input.dart';
import 'package:burger_review_3/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  Uint8List? _smallProfImage;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text(
                        'Photo Library',
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text(
                      'Camera',
                      style: TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _imgFromGallery() async {
    Uint8List im = await pickImage(ImageSource.gallery, 250);
    setState(() {
      _image = im;
    });
  }

  void _imgFromCamera() async {
    Uint8List im = await pickImage(ImageSource.camera, 250);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    _smallProfImage = _image;
    if (_smallProfImage != null){
      _smallProfImage = await FlutterImageCompress.compressWithList(_smallProfImage!, quality: 1);
      _smallProfImage = await FlutterImageCompress.compressWithList(_smallProfImage!, quality: 1);
    }
    String res = await AuthMethods().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        file: _image,
        smallProfImage: _smallProfImage);
    setState(() {
      _isLoading = false;
    });
    if (res != 'success') {
      showFlushBar(res, context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyApp()//MyHomePage(title: 'Home Page'),
        ),
      );
    }
  }

  void navigateToLogIn() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: kPrimaryColor, title: Text('Sign Up'),),
      backgroundColor: kBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              child: IntrinsicHeight(
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 10),
                              child: _image != null
                                  ? CircleAvatar(
                                      radius: 64,
                                      backgroundImage: MemoryImage(_image!),
                                    )
                                  : const CircleAvatar(
                                      radius: 64,
                                      backgroundImage: AssetImage(
                                          'assets/Icons/defaultProfileIcon.jpg'),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 80,
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border:
                                      Border.all(width: 2, color: Colors.black),
                                  color: Colors.white,
                                ),
                                child: IconButton(
                                  iconSize: 20,
                                  onPressed: selectImage,
                                  icon: const Icon(Icons.add_a_photo),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFieldInput(
                            textEditingController: _usernameController,
                            hintText: 'Enter your username',
                            textInputType: TextInputType.text),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFieldInput(
                            textEditingController: _emailController,
                            hintText: 'Enter your email',
                            textInputType: TextInputType.emailAddress),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFieldInput(
                          textEditingController: _passwordController,
                          hintText: 'Enter your password',
                          textInputType: TextInputType.text,
                          isPass: true,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            //color: Colors.grey[250]
                          ),
                          child: TextField(
                              controller: _bioController,
                              decoration: InputDecoration(
                                hintText: 'Enter bio',
                                filled: true,
                                fillColor: Colors.grey[250],
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.1),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 0.5),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.1),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              maxLines: 2,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(color: Colors.black),
                              keyboardType: TextInputType.text),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: signUpUser,
                          child: Container(
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Sign up',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(12),
                            decoration: const ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                                color: Colors.blue),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Flexible(
                          child: Container(),
                          flex: 2,
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Container(
                        //       child: const Text(
                        //         "Have an account?",
                        //         style: const TextStyle(color: Colors.black),
                        //       ),
                        //       padding: const EdgeInsets.symmetric(
                        //         vertical: 8,
                        //       ),
                        //     ),
                        //     GestureDetector(
                        //       onTap: navigateToLogIn,
                        //       child: Container(
                        //         child: const Text(
                        //           " Login",
                        //           style: TextStyle(
                        //               fontWeight: FontWeight.bold,
                        //               color: Colors.black),
                        //         ),
                        //         padding: const EdgeInsets.symmetric(
                        //           vertical: 8,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
