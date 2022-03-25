import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'log_service.dart';

class FileService {
  static final _storage = FirebaseStorage.instance.ref();
  static const folderPost = "post_images";
  static const folderUser = "user_images";

  static Future<String> uploadImage(File _image, String folder) async {
    // image name
    String imgName = "image_" + DateTime.now().toString();
    Reference storageRef = _storage.child(folder).child(imgName);
    UploadTask uploadTask = storageRef.putFile(_image);
    TaskSnapshot taskSnapshot = await uploadTask;

    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    Log.d(downloadUrl);
    return downloadUrl;
  }
}
