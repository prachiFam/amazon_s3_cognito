## 0.1.8
Resolved all the issues for IOS and Android. 
Android is compatible with Android X release

## 0.1.9
Resolved bug on android -> when image is uploaded to s3 and image upload fails,
 the app crashes. 
 
## 0.2.0
updated readme to contain proper instruction set

## 0.2.1
updated kotlin version in android to resolve conflicts with flutter version 1.9 and updated android studio version.
## 0.2.3
added new regions into the package.

## 0.2.4
plugin now supports pdf and other file type uploads.
Other file uploads were working properly on Android before, but they were broken for IOS, so we have fixed those now too.
NOTE **** Use upload method in order to upload files other than images.

## 0.4.0
Buggy -> do not use
Do not use this version. older or newer version instead

## 0.4.1
Buggy -> do not use
plugin is not fixed for xcode version 12


## 0.5.0
plugin is now working for ios upload also. However plugin is still not
using TransferUtiltiy classes as thosee are giving issues on image uploads.

## 0.5.2
the documents and image urls path are now returned correctly.

## 0.6.0
prerelease -> this version includes null safety

## 0.7.0
Breaking changes area added.
1) fixed issue : The plugins amazon_s3_cognito, version of the Android embedding
2) Added methods that can upload multiple images via a list
3) When using multiple image upload, we can listen to image upload using event stream
4) for IOS app now uses TransferUtility API's, since TransferManager API's are depracated
5) Now all methods take subFolder to which we want to upload/ delete image.

## 0.7.3
1) fixed issue that on IOS image upload was not working.