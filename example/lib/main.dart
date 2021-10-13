import 'dart:async';
import 'dart:collection';
import 'dart:html';

import 'package:amazon_s3_cognito/amazon_s3_cognito.dart';
import 'package:amazon_s3_cognito/image_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  EventChannel _amazonS3Stream =
      EventChannel('amazon_s3_cognito_images_upload_steam');
  StreamSubscription? uploadListenerSubscription;

  List<ImageData> filesToUpload = [];

  @override
  void initState() {
    super.initState();
    _listenToFileUpload();
  }

  void _listenToFileUpload() {
    //when you want to upload multi-files or listen to upload then
    //you get the image progress via this stream
    uploadListenerSubscription =
        _amazonS3Stream.receiveBroadcastStream().listen((event) {
      LinkedHashMap<Object?, Object?> map = event;
      print(map);
      ImageData imageData = ImageData.fromMap(map);
      //update the ui based on the object returned in stream
    });
  }

  void uploadMultipleFileUploads() async {
    String bucketName = "test";
    String cognitoPoolId = "your pool id";
    String bucketRegion = "imageUploadRegion";
    String bucketSubRegion = "Sub region of bucket";

    //fileUploadFolder - this is optional parameter
    String fileUploadFolder =
        "folder inside bucket where we want file to be uploaded";

    String filePath = ""; //path of file you want to upload
    ImageData imageData = ImageData("uniqueFileName", filePath,
        uniqueId: "uniqueIdToTrackImage", imageUploadFolder: fileUploadFolder);
    filesToUpload.add(imageData);
    filesToUpload.add(imageData);
    filesToUpload.add(imageData);

    //needProgressUpdateAlso - in event stream you will get progress of the image also
    //needMultipartUpload - only applicable for IOS, when your uploads are so large that they take more than 1 hour to complete set its value to true
    await AmazonS3Cognito.uploadImages(bucketName, cognitoPoolId, bucketRegion,
        bucketSubRegion, filesToUpload, false);
  }

  void uploadSingleImage() async {
    String bucketName = "test";
    String cognitoPoolId = "your pool id";
    String bucketRegion = "imageUploadRegion";
    String bucketSubRegion = "Sub region of bucket";

    //fileUploadFolder - this is optional parameter
    String fileUploadFolder =
        "folder inside bucket where we want file to be uploaded";

    String filePath = ""; //path of file you want to upload
    ImageData imageData = ImageData("uniqueFileName", filePath,
        uniqueId: "uniqueIdToTrackImage", imageUploadFolder: fileUploadFolder);

    //result is either amazon s3 url or failure reason
    String? result = await AmazonS3Cognito.upload(
        bucketName, cognitoPoolId, bucketRegion, bucketSubRegion, imageData,
        needMultipartUpload: true);
    //once upload is success or failure update the ui accordingly
    print(result);
  }

  void deleteImage() async {
    String cognitoPoolId = "your pool id";
    String bucketRegion = "imageUploadRegion";
    String bucketSubRegion = "Sub region of bucket";

    //fileUploadFolder - this is optional parameter
    //folder inside bucket where file exists
    //example - if file is there in test/101/abc.jpg. where test is bucket name
    //then fileUploadFolder = "101/"

    String bucketName = "test";
    String fileUploadFolder = "101/";
    String fileName = "abc.jpg";

    String? result = await AmazonS3Cognito.delete(bucketName, cognitoPoolId,
        fileName, fileUploadFolder, bucketRegion, bucketSubRegion);

    if (result != null) {
      print(result);
    }
  }

  void dispose() {
    super.dispose();
    uploadListenerSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
