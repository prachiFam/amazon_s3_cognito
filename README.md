# amazon_s3_cognito


Amazon S3 plugin for Flutter

Unofficial Amazon S3 plugin written in Dart for Flutter.

The plugin is extension if flutter-amazon-s3 plugin which can be found here 
https://pub.dev/packages/flutter_amazon_s3. This plugin adds image delete functionality and also
it allows user to upload image when region and sub-region are different.

Plugin in maintained by fäm properties<no-reply@famproperties.com>.

## Usage
To use this plugin, add `amazon_s3_cognito` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).


```yaml
dependencies:
Use this version pre-android x, for other version we are still experimenting with the code
  amazon_s3_cognito: '^0.1.8' 
```

### Example



``` dart
import 'package:amazon_s3_cognito/amazon_s3_cognito.dart';
import 'package:amazon_s3_cognito/aws_region.dart';

String uploadedImageUrl = await AmazonS3Cognito.uploadImage(
          _image.path, BUCKET_NAME, IDENTITY_POOL_ID);
          

//Use the below code to specify the region and sub region for image upload
String uploadedImageUrl = await AmazonS3Cognito.upload(
            _image.path,
            BUCKET_NAME,
            IDENTITY_POOL_ID,
            IMAGE_NAME,
            AwsRegion.US_EAST_1,
            AwsRegion.AP_SOUTHEAST_1)
            
//use below code to delete an image
 String result = AmazonS3Cognito.delete(
            BUCKET_NAME,
            IDENTITY_POOL_ID,
            IMAGE_NAME,
            AwsRegion.US_EAST_1,
            AwsRegion.AP_SOUTHEAST_1)
            
            
        

```
          
## Installation


### Android

No configuration required - the plugin should work out of the box.          


### iOS

No configuration required - the plugin should work out of the box.          

### Authors
```
the plugin is created and maintained by fäm properties. 
Android version written by Prachi Shrivastava
IOS version written by Prachi Shrivastava
```
