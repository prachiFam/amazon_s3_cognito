import Flutter
import UIKit
import AWSS3
import AWSCore


public class SwiftAmazonS3CognitoPlugin: NSObject, FlutterPlugin {

  


  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "amazon_s3_cognito", binaryMessenger: registrar.messenger())
    let instance = SwiftAmazonS3CognitoPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
         if(call.method.elementsEqual("uploadImage")){
              uploadImageForRegion(call,result: result)
          }else if(call.method.elementsEqual("deleteImage")){
              deleteImage(call,result: result)
          }
      }
    
    
    
    func uploadImageForRegion(_ call: FlutterMethodCall, result: @escaping FlutterResult){
              let arguments = call.arguments as? NSDictionary
              let imagePath = arguments!["filePath"] as? String
              let bucket = arguments!["bucket"] as? String
              let identity = arguments!["identity"] as? String
              let fileName = arguments!["imageName"] as? String
              let region = arguments!["region"] as? String
              let subRegion = arguments!["subRegion"] as? String

            let contentTypeParam = arguments!["contentType"] as? String


              print("region" + region!)
        
        let awsHelper:AwsImageUploadHelper = AwsImageUploadHelper.init()
        
        awsHelper.uploadImageForRegion(imagePath: imagePath, bucket: bucket, identity: identity, fileName: fileName, region: region, subRegion: subRegion, contentTypeParam: contentTypeParam) { (awsUploadReult) in
            result(awsUploadReult)}
        
    }

    func deleteImage(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        let arguments = call.arguments as? NSDictionary
        let bucket = arguments!["bucket"] as? String
        let identity = arguments!["identity"] as? String
        let fileName = arguments!["imageName"] as? String
        let region = arguments!["region"] as? String
        let subRegion = arguments!["subRegion"] as? String

        let awsHelper:AwsImageUploadHelper = AwsImageUploadHelper.init()
        
        awsHelper.deleteImage(bucket: bucket, identity: identity, fileName: fileName, region: region, subRegion: subRegion) { deleteImageResult in
            result(deleteImageResult)}
        
    
    }


}
