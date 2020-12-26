import 'dart:async';

import 'package:flutter/services.dart';

class AmazonS3Cognito {
  static const MethodChannel _channel =
      const MethodChannel('amazon_s3_cognito');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> uploadImage(
      String filepath, String bucket, String identity) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'filePath': filepath,
      'bucket': bucket,
      'identity': identity,
    };
    final String imagePath =
        await _channel.invokeMethod('uploadImageToAmazon', params);
    return imagePath;
  }

  static Future<String> upload(String filepath, String bucket, String identity,
      String imageName, String region, String subRegion) async {
    print('Region: ' + region + ' subRegion: ' + subRegion);
    try {
      final Map<String, dynamic> params = <String, dynamic>{
        'filePath': filepath,
        'bucket': bucket,
        'identity': identity,
        'imageName': imageName,
        'region': region,
        'subRegion': subRegion
      };
      final String imagePath =
          await _channel.invokeMethod('uploadImage', params);
      return imagePath;
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return '';
  }

  static Future<String> delete(String bucket, String identity, String imageName,
      String region, String subRegion) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'bucket': bucket,
      'identity': identity,
      'imageName': imageName,
      'region': region,
      'subRegion': subRegion
    };
    final String imagePath = await _channel.invokeMethod('deleteImage', params);
    return imagePath;
  }

  static Future<List<String>> listFiles(
      String bucket,
      String identity,
      String prefix,
      String region,
      String subRegion,
      String cloudFrontWebUrl) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'bucket': bucket,
      'identity': identity,
      'prefix': prefix,
      'region': region,
      'subRegion': subRegion
    };
    List<String> files = new List();
    try {
      List<dynamic> keys = await _channel.invokeMethod('listFiles', params);
      for (String key in keys) {
        files.add("$cloudFrontWebUrl$bucket/$key");
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }

    return files;
  }
}
