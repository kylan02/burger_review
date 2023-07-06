
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

pickImage(ImageSource source, double maxWidth) async {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _file = await _imagePicker.pickImage(source: source, maxWidth: maxWidth);

  if (_file != null) {
    Uint8List _fileList = await _file.readAsBytes();
    return await FlutterImageCompress.compressWithList(_fileList, quality: 80);
  }
  print('No image selected');
}

pickVideo(ImageSource source) async{
  final ImagePicker _imagePicker = ImagePicker();

  final _vidFile = await _imagePicker.pickVideo(source: source, maxDuration: const Duration(minutes: 8));

  if (_vidFile != null) {
    return _vidFile;
  }
  print('No video selected');
}

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

showFlushBar(String content, BuildContext context){
  Flushbar(
    //title:  "Hey Ninja",
    message:  content,

    duration:  const Duration(seconds: 3),
    flushbarPosition: FlushbarPosition.TOP,
  ).show(context);
}

