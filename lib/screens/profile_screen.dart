/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:burger_review_3/models/user.dart' as model;
import '../constants.dart';
import '../providers/user_provider.dart';
import '../text_field_input.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.id}) : super(key: key);
  final id;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  late model.user user;
  String username = "";

  void fetchUserData() async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.refreshUser();
    print("in add data");
    setState(() {
      user = Provider.of<UserProvider>(context, listen: false).getUser!;
      username = user.username;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text('Profile'),
      ),
      body: FutureBuilder(
        future: fetchUserData(widget.id),
        builder: (context, AsyncSnapshot snapshot) {
          return Column(
            children: [
              Container(
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
                              border: Border.all(width: 2, color: Colors.black),
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
                                    fontWeight: FontWeight.bold, fontSize: 16),
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
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
*/