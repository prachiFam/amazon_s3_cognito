import Flutter
import UIKit
import AWSS3
import AWSCore


public class SwiftAmazonS3CognitoPlugin: NSObject, FlutterPlugin {

private static let imageUploadEventChannel:String = "amazon_s3_cognito_images_upload_steam"

private static  var imageUploadStreamHandler = ImageUploadStreamHandler()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "amazon_s3_cognito", binaryMessenger: registrar.messenger())


    FlutterEventChannel(name: imageUploadEventChannel, binaryMessenger: registrar.messenger())
        .setStreamHandler(imageUploadStreamHandler)

    let instance = SwiftAmazonS3CognitoPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
         if(call.method.elementsEqual("uploadImage")){
            uploadSingleImage(call,result: result)
          }else if(call.method.elementsEqual("deleteImage")){
              deleteImage(call,result: result)
          }else if(call.method.elementsEqual("uploadImages")){
            uploadMultipleImages(call,result: result)
        }
      }

    func uploadSingleImage(_ call: FlutterMethodCall, result: @escaping FlutterResult){
              let arguments = call.arguments as? NSDictionary
        let imagePath:String = arguments!["filePath"] as! String
        let bucket:String = arguments!["bucket"] as! String

        let imageUploadFolder:String? = arguments!["imageUploadFolder"] as? String

        let identity:String = arguments!["identity"] as! String

        let fileName = arguments!["imageName"] as! String


        let region = arguments!["region"] as! String

        let subRegion = arguments!["subRegion"] as! String



        let contentTypeParam = arguments!["contentType"] as? String

        var uniqueId = arguments!["uniqueId"] as? String

        if(uniqueId == nil){
            uniqueId = "-1"
        }

        var needMultipartUpload = arguments!["needMultipartUpload"] as? Bool

        if(needMultipartUpload == nil){
            needMultipartUpload = false
        }


        let multiAwsUploadHelper:AwsMultiImageUploadHelper = AwsMultiImageUploadHelper.init(region: region, subRegion: subRegion, identity: identity, bucketName: bucket, needFileProgressUpdateAlso: false)


        let imageData:ImageData = ImageData(filePath: imagePath, fileName: fileName, uniqueId: uniqueId!, contentType: contentTypeParam, imageFolderInBucket: imageUploadFolder)

        if(needMultipartUpload!){

            multiAwsUploadHelper.uploadVeryLargeSingleFile(imageDataObj: imageData){ (awsUploadResult) in

                print("reesult is " + awsUploadResult)

                result(awsUploadResult)

            }


        }else{
            multiAwsUploadHelper.uploadSingleFile(imageDataObj: imageData){ (awsUploadResult) in

                print("reesult is " + awsUploadResult)

                result(awsUploadResult)

            }

        }


    }

    func uploadMultipleImages(_ call: FlutterMethodCall, result: @escaping FlutterResult)  {

        let arguments = call.arguments as? NSDictionary

        let bucket = arguments!["bucket"] as? String
        let identityPoolId = arguments!["identity"] as? String
        let region = arguments!["region"] as? String
        let subRegion = arguments!["subRegion"] as? String

        let needFileProgressUpdateAlso = arguments!["needProgressUpdateAlso"] as? Bool

        var needMultipartUpload = arguments!["needMultipartUpload"] as? Bool

        if(needMultipartUpload == nil){
            needMultipartUpload = false
        }

        var needProgressUpdate:Bool = false
        if(needFileProgressUpdateAlso != nil){
            needProgressUpdate = needFileProgressUpdateAlso!
        }

        let imagesListString = arguments!["imageDataList"] as? String

        if(imagesListString != nil){

            let jsonData = imagesListString!.data(using: .utf8)!

            var images:[ImageData] = []
            if let json = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [Any] {
                for item in json {
                    if let object = item as? [String: Any] {
                        // ID

                        let filePath = object["filePath"] as! String
                        let fileName = object["fileName"] as! String
                        let uniqueId = object["uniqueId"] as! String
                        let contentType = object["contentType"] as? String

                        let imageUploadFolder = object["imageUploadFolder"] as? String

                        let imageDataInner:ImageData = ImageData(filePath: filePath, fileName: fileName, uniqueId: uniqueId, contentType: contentType,imageFolderInBucket: imageUploadFolder)
                         images.append(imageDataInner)

                    }
                }

            }


            if(region == nil || subRegion == nil || bucket == nil || identityPoolId == nil  ){
                result("function parameters are not supplied properly. Region, subregion, buckernamen identityPoolId cannot be null or empty")
            }else{
                let multiAwsUploadHelper:AwsMultiImageUploadHelper = AwsMultiImageUploadHelper.init(region: region!, subRegion: subRegion!, identity: identityPoolId!, bucketName: bucket!, needFileProgressUpdateAlso: needProgressUpdate)

                if(!needMultipartUpload!){
                    multiAwsUploadHelper.uploadMultipleImages(imagesData:images, imageUploadSreamHelper:SwiftAmazonS3CognitoPlugin.imageUploadStreamHandler)
                }else{
                    multiAwsUploadHelper.uploadVeryLargeFiles(imagesData:images, imageUploadSreamHelper:SwiftAmazonS3CognitoPlugin.imageUploadStreamHandler)
                }

            }
        }else{
            result("image list is empty")
        }



    }

    func deleteImage(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        let arguments = call.arguments as? NSDictionary
        let bucket = arguments!["bucket"] as! String
        let identity = arguments!["identity"] as! String
        let fileName = arguments!["imageName"] as! String
        let region = arguments!["region"] as! String
        let subRegion = arguments!["subRegion"] as! String

        let imageUploadFolder = arguments!["imageUploadFolder"] as? String

        let multiAwsUploadHelper:AwsMultiImageUploadHelper = AwsMultiImageUploadHelper.init(region: region, subRegion: subRegion, identity: identity, bucketName: bucket, needFileProgressUpdateAlso: false)


        multiAwsUploadHelper.deleteImage(fileName: fileName, folderToUploadTo: imageUploadFolder)
            { deleteImageResult in
                result(deleteImageResult)
        }


    }


}
