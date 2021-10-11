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
              uploadImageForRegion(call,result: result)
          }else if(call.method.elementsEqual("deleteImage")){
              deleteImage(call,result: result)
          }else if(call.method.elementsEqual("uploadImages")){
            uploadMultipleImages(call,result: result)
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
    
    func uploadMultipleImages(_ call: FlutterMethodCall, result: @escaping FlutterResult)  {
        
        let arguments = call.arguments as? NSDictionary
        
        let bucket = arguments!["bucket"] as? String
        let identityPoolId = arguments!["identity"] as? String
        let region = arguments!["region"] as? String
        let subRegion = arguments!["subRegion"] as? String
        
        let needFileProgressUpdateAlso = arguments!["needProgressUpdateAlso"] as? Bool
        
        var needProgressUpdate:Bool = false
        if(needFileProgressUpdateAlso != nil){
            needProgressUpdate = needFileProgressUpdateAlso!
        }
        
        let imagesListString = arguments!["imageDataList"] as? String
        
        if(imagesListString != nil){
            
            let jsonData = imagesListString!.data(using: .utf8)!
            

            if let json = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [Any] {
                for item in json {
                    if let object = item as? [String: Any] {
                        // ID
                        
                        let filePath = object["filePath"] as! String
                        let fileName = object["fileName"] as! String
                        let uniqueId = object["uniqueId"] as! String
                        let contentType = object["contentType"] as? String
                        
                        let imageDataInner:ImageData = ImageData(filePath: filePath, fileName: fileName, uniqueId: uniqueId, contentType: contentType)
                        
                       
                        
                    }
                }
            
            }
            
            
            if(region == nil || subRegion == nil || bucket == nil || identityPoolId == nil  ){
                result("function paramters are not supplied properly. Region, subregion, buckernamen identityPoolId cannot be null or empty")
            }else{
                let multiAwsUploadHelper:AwsMultiImageUploadHelper = AwsMultiImageUploadHelper.init(region: region!, subRegion: subRegion!, identity: identityPoolId!, bucketName: bucket!, needFileProgressUpdateAlso: needProgressUpdate)
                
                multiAwsUploadHelper.uploadMultipleImages(imagesData: [], imageUploadSreamHelper:SwiftAmazonS3CognitoPlugin.imageUploadStreamHandler)
            }
        }else{
            result("image list is empty")
        }
        
        
        
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
