import 'dart:io';
import 'dart:math';

import '../../fireflutter.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:firebase_storage/firebase_storage.dart';

class FileStorageService {
  static FileStorageService? _instance;
  static FileStorageService get instance {
    _instance ??= FileStorageService();
    return _instance!;
  }

  final firebaseStorage = FirebaseStorage.instance;

  Future<String> pickUpload({
    required ImageSource source,
    int quality = 90,
    Function(double)? onProgress,
  }) async {
    // print('pickUpload;');

    /// Pick image
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    /// No image picked. Throw error.
    if (pickedFile == null) throw ERROR_IMAGE_NOT_SELECTED;

    /// Compress image. Fix Exif data.
    File file = await _imageCompressor(pickedFile.path, quality);

    /// Reference
    final String filenameExtension = file.path.split('/').last;
    Reference ref = firebaseStorage.ref("uploads/$filenameExtension");
    // Thumbnail ref
    final String filename = filenameExtension.split('.').first;

    // Upload Task
    UploadTask uploadTask = ref.putFile(file);

    /// Progress listener
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((event) {
        double progress = event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
        onProgress(progress);
      });
    }

    /// Wait for upload to finish.
    await uploadTask;

    await Future.delayed(Duration(seconds: 1));

    /// Return uploaded file Url.
    // return ref.getDownloadURL();
    /// Return uploaded file thumbnail Url.
    return getThumbnailUrl(filename, 10);
  }

  /// Returns url of created thumbnail.
  ///
  /// It runs recursively until the url is resolve or it runs out of retry.
  ///
  /// We don't know how long the thumbnail url will be created.
  /// https://stackoverflow.com/a/58978012
  Future<String> getThumbnailUrl(String filename, [int retry = 5]) async {
    final ref = firebaseStorage.ref("uploads/$filename" + "_200x200.webp");

    /// Retries
    if (retry < 0) {
      return Future.error('File not found.');
    }

    try {
      await Future.delayed(Duration(seconds: 2));
      return ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found' && retry != 0) {
        return getThumbnailUrl(filename, retry - 1);
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// TODO: Delete original and thumbnail image on storage.
  Future<void> delete(String url) async {
    try {
      await firebaseStorage.refFromURL(url).delete();
    } on FirebaseException catch (e) {
      print('firebase storage error ====> $e');
      if (e.code != 'object-not-found') rethrow;
    } catch (e) {
      rethrow;
    }
  }

  ///
  /// HELPER FUNCTIONS
  ///

  /// 파일을 압축하고, 가로/세로를 맞춘다.
  _imageCompressor(String filepath, int quality) async {
    /// This method will be called when image was taken by [Api.takeUploadFile].
    /// It can compress the image and then return it as a File object.

    String localFile = await _getAbsoluteTemporaryFilePath(_getRandomString() + '.jpeg');
    File? file = await FlutterImageCompress.compressAndGetFile(
      filepath, // source file
      localFile, // target file. Overwrite the source with compressed.
      quality: quality,
    );

    return file;
  }

  Future<String> _getAbsoluteTemporaryFilePath(String relativePath) async {
    var directory = await getTemporaryDirectory();
    return p.join(directory.path, relativePath);
  }

  String _getRandomString({int len = 16, String? prefix}) {
    const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
    var t = '';
    for (var i = 0; i < len; i++) {
      t += charset[(Random().nextInt(charset.length))];
    }
    if (prefix != null && prefix.isNotEmpty) t = prefix + t;
    return t;
  }
}
