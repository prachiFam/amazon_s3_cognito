import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'image_data.dart';

class AmazonS3Cognito {
  static const MethodChannel _channel =
      const MethodChannel('amazon_s3_cognito');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> upload(String bucket, String identity, String region,
      String subRegion, ImageData imageData,
      {bool needMultipartUpload = false}) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'filePath': imageData.filePath,
      'bucket': bucket,
      'identity': identity,
      'imageName': imageData.fileName,
      'imageUploadFolder': imageData.imageUploadFolder,
      'region': region,
      'subRegion': subRegion,
      'uniqueId': imageData.uniqueId,

      /// needMultipartUpload - use this parameter when your files are
      /// very large and file uploads take more than 1 hour time
      /// for small files with uploads less than hour this must be false
      /// this is only available for IOS
      'needMultipartUpload': needMultipartUpload
    };
    final String? imagePath =
        await _channel.invokeMethod('uploadImage', params);
    return imagePath;
  }

  static Future<String?> delete(
      String bucket,
      String identity,
      String imageName,
      String? folderInBucketWhereImgIsUploaded,
      String region,
      String subRegion) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'bucket': bucket,
      'identity': identity,
      'imageName': imageName,
      'region': region,
      'subRegion': subRegion,
      'imageUploadFolder': folderInBucketWhereImgIsUploaded,
    };
    final String? imagePath =
        await _channel.invokeMethod('deleteImage', params);
    return imagePath;
  }

  static Future<String?> uploadImages(
      String bucket,
      String identity,
      String region,
      String subRegion,
      List<ImageData> imageData,
      bool needProgressUpdateAlso,
      {bool needMultipartUpload = false}) async {
    String imageDataList = json.encode(imageData);

    final Map<String, dynamic> params = <String, dynamic>{
      'bucket': bucket,
      'identity': identity,
      'region': region,
      'subRegion': subRegion,
      'imageDataList': imageDataList,
      'needProgressUpdateAlso': needProgressUpdateAlso,

      /// needMultipartUpload - use this parameter when your files are
      /// very large and file uploads take more than 1 hour time
      /// for small files with uploads less than hour this must be false
      /// this is only available for IOS
      'needMultipartUpload': needMultipartUpload
    };
    final String? imagePath =
        await _channel.invokeMethod('uploadImages', params);
    return imagePath;
  }
}
