import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static const String MAIN_TAG = '## ImageHelper';

  static Future<File> selectImage({String imgSource = 'camera'}) async {
    log('$MAIN_TAG selectImage()');
    final picker = ImagePicker();
    ImageSource imageSource;
    switch (imgSource) {
      case 'camera':
        {
          imageSource = ImageSource.camera;
          break;
        }
      case 'gallery':
        {
          imageSource = ImageSource.gallery;
          break;
        }
      default:
        {
          imageSource = ImageSource.camera;
        }
    }
    try {
      final pickedFile = await picker.getImage(
        source: imageSource,
        maxWidth: 1400,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      } else {
        log('Image not picked');
        throw 'Image not picked';
      }
    } catch (error) {
      throw error;
    }
  }
}
