import 'dart:io';
import 'dart:typed_data';

import 'package:burger_review_3/constants.dart';
import 'package:burger_review_3/models/media_source.dart';
import 'package:burger_review_3/providers/user_provider.dart';
import 'package:burger_review_3/screens/social_page.dart';
import 'package:burger_review_3/text_field_input.dart';
import 'package:burger_review_3/utils.dart';
import 'package:burger_review_3/widgets/video_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:burger_review_3/models/user.dart' as model;

import '../resources/firestore_methods.dart';
import '../main.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key, required this.id, required this.name})
      : super(key: key);

  final String id;
  final String name;

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _postDescriptionController =
      TextEditingController();

  late model.User user;
  Uint8List? _image;
  File? _file;
  bool _isLoading = false;
  double _rating = 10;
  double _ratingOutOf100 = 100;
  late MediaSource source;
  late Image finalImage;

  @override
  void dispose() {
    super.dispose();
    _postDescriptionController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addData();
  }

  Future addData() async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.refreshUser();
    print("in add data");
    setState(() {
      user = Provider.of<UserProvider>(context, listen: false).getUser!;
    });
  }

  void postImage(
    String uid,
    String username,
    String profImage,
  ) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadImagePost(
        _postDescriptionController.text,
        _image!,
        uid,
        username,
        profImage,
        widget.id,
        widget.name,
        _rating,
      );

      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
        //showSnackBar('Posted!', context);

        Navigator.of(context).pop();

      } else {
        showSnackBar(res, context);
      }
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
  }

  void postVideo(
      String uid,
      String username,
      String profImage,
      ) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadVideoPost(
        _postDescriptionController.text,
        _file!,
        uid,
        username,
        profImage,
        widget.id,
        widget.name,
        _rating,
      );

      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
        //await showSnackBar('Posted!', context);

        Navigator.of(context).pop();
      } else {
        showSnackBar(res, context);
      }
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
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
                    leading: const Icon(Icons.photo_camera),
                    title: const Text(
                      'Picture',
                      style: TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text(
                      'Video',
                      style: TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      _videoFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _imgFromCamera() async {
    Uint8List im = await pickImage(ImageSource.camera, 500);
    setState(() {
      source = MediaSource.image;
      _image = im;
    });
  }

  void _videoFromCamera() async {
    XFile vid = await pickVideo(ImageSource.camera);
    setState(() {
      source = MediaSource.video;
      _file = File(vid.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text('Leave a Review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            positionInStack = 'RestaurantInfoPage';
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: IntrinsicHeight(
          child: SafeArea(
            child: Column(
              children: [
                _isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(
                        padding: EdgeInsets.only(top: 0),
                      ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Review ${widget.name}:',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          child: (_image != null || _file != null)
                              ? Container(
                                  child: (() {
                                    if (source == MediaSource.image) {
                                      finalImage = Image.memory(
                                        _image!,
                                        width: 250,
                                        height: 250,
                                        fit: BoxFit.cover,
                                        scale: 2,
                                      );
                                      return finalImage; //image: MemoryImage(_image!),
                                    } else if (source == MediaSource.video) {
                                      return VideoWidget(_file!, '', false, 250, 250);
                                      //   Container(
                                      //   height: 200,
                                      //   width: 200,
                                      //   child: FittedBox(
                                      //     clipBehavior: Clip.hardEdge,
                                      //     child: VideoWidget(file!),
                                      //     fit: BoxFit.cover,
                                      //   ),
                                      // );
                                    }
                                  }()),
                                )
                              : Container(
                                  color: Colors.grey[350],
                                  child: const Image(
                                    image: AssetImage(
                                        'assets/Icons/addMediaIcon.png'),
                                  ),
                                  height: 250,
                                  padding: const EdgeInsets.all(80),
                                ),
                          onTap: () {
                            if (_file == null) {
                              selectImage();
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Score: ${_rating}',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Slider.adaptive(
                        activeColor: kPrimaryColor,
                        value: (_ratingOutOf100),
                        onChanged: (newRating) {
                          setState(() {
                            _ratingOutOf100 = newRating;
                            _rating = (newRating).roundToDouble() / 10;
                          });
                        },
                        divisions: 100,
                        min: 0,
                        max: 100,
                        //label: '${_rating}',
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
                            controller: _postDescriptionController,
                            decoration: InputDecoration(
                              hintText: 'Write something...',
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
                            maxLines: 5,
                            textCapitalization: TextCapitalization.sentences,
                            style: const TextStyle(color: Colors.black),
                            keyboardType: TextInputType.text),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // SizedBox(
                      //   height: 100,
                      // ),
                      InkWell(
                        onTap: () {
                          if(!_isLoading){
                            if(_file != null){
                              postVideo(user.uid, user.username, user.smallPhotoUrl);
                            }
                            else if(_image != null){
                              postImage(user.uid, user.username, user.smallPhotoUrl);
                            }
                          }else{
                            print('Implement popup error saying I didnt select any media yet');
                          }
                        },
                        child: Container(
                          //height: 50,
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
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
                    ],
                  ),
                ),
                Flexible(
                  child: Container(),
                  flex: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
