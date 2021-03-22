import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import '../helpers/image_helper.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;

/// Provides picking an image from the [source] (the camera or the gallery) and save it
/// in the [appDir] directory
class ImageInput extends StatefulWidget {
  final Function onSelectImage;
  ImageInput(this.onSelectImage);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  static const String MAIN_TAG = '## ImageInput';
  File _storedImage;
  File _savedImage;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Row(children: [
      Container(
        height: 100,
        width: deviceSize.width * 0.4,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.grey,
          ),
        ),
        child: _savedImage != null
            ? Image.file(
                _savedImage,
                fit: BoxFit.cover,
                width: double.infinity,
              )
            : Text(
                'Not Image Taken',
                textAlign: TextAlign.center,
              ),
        alignment: Alignment.center,
      ),
      Expanded(
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Column(
            children: [
              SizedBox(height: 10),
              TextButton.icon(
                icon: Icon(Icons.camera),
                label: Text(
                  'Take Picture from Camera',
                  overflow: TextOverflow.clip,
                  maxLines: 2,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () => _pickImage(source: 'camera'), //from Camera
              ),
              SizedBox(height: 10),
              TextButton.icon(
                icon: Icon(Icons.collections),
                label: Text(
                  'Take Picture from Gallery',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () => _pickImage(source: 'gallery'), // from Gallery
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  /// The method pick an image from the [source] and save it
  /// in the [appDir] directory
  Future<void> _pickImage({String source = 'camera'}) async {
    log('$MAIN_TAG _pickImage()');
    _storedImage = await ImageHelper.selectImage(imgSource: source);
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(_storedImage.path);
    _savedImage = await _storedImage.copy('${appDir.path}/$fileName');
    //callback that set in the calling side
    widget.onSelectImage(_savedImage);
    setState(() {
      log('$MAIN_TAG _pickImage() -> setState()');
    });
  }
}
