import Flutter
import UIKit
import AWSS3
import AWSCore


public class SwiftAmazonS3CognitoPlugin: NSObject, FlutterPlugin {

   var region1:AWSRegionType = AWSRegionType.USEast1
   var subRegion1:AWSRegionType = AWSRegionType.USEast1




  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "amazon_s3_cognito", binaryMessenger: registrar.messenger())
    let instance = SwiftAmazonS3CognitoPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
          if(call.method.elementsEqual("uploadImageToAmazon")){
              let arguments = call.arguments as? NSDictionary
              let imagePath = arguments!["filePath"] as? String
              let bucket = arguments!["bucket"] as? String
              let identity = arguments!["identity"] as? String

              var imageAmazonUrl = ""
              let fileUrl = NSURL(fileURLWithPath: imagePath!)

              let uploadRequest = AWSS3TransferManagerUploadRequest()
              uploadRequest?.bucket = bucket
              uploadRequest?.key = nameGenerator()

            var contentType = "image/jpeg"
            if(imagePath!.contains(".")){
                var index = imagePath!.lastIndex(of: ".")
                index = imagePath!.index(index!, offsetBy: 1)
                if(index != nil){
                    let extention = String(imagePath![index!...])
                    print("extension"+extention);
                    if(extention.lowercased().contains("png") ||
                    extention.lowercased().contains("jpg") ||
                        extention.lowercased().contains("jpeg") ){
                        contentType = "image/"+extention
                    }else{
                        if(contentType.contains("pdf")){
                             contentType = "application/pdf";
                        }else{
                             contentType = "application/*";
                        }

                    }

                }
            }

            uploadRequest?.contentType = contentType

              uploadRequest?.body = fileUrl as URL
              uploadRequest?.acl = .publicReadWrite

              let credentialsProvider = AWSCognitoCredentialsProvider(
                  regionType: AWSRegionType.USEast1,
                  identityPoolId: identity!)
              let configuration = AWSServiceConfiguration(
                  region: AWSRegionType.USEast1,
                  credentialsProvider: credentialsProvider)
              AWSServiceManager.default().defaultServiceConfiguration = configuration

              AWSS3TransferManager.default().upload(uploadRequest!).continueWith { (task) -> AnyObject? in
                  if let error = task.error {
                      print("❌ Upload failed (\(error))")
                  }
                  if task.result != nil {
                      imageAmazonUrl = "https://s3.amazonaws.com/\(bucket!)/\(uploadRequest!.key!)"
                      print("✅ Upload successed (\(imageAmazonUrl))")
                  } else {
                      print("❌ Unexpected empty result.")
                  }
                  result(imageAmazonUrl)
                  return nil
              }
          }else if(call.method.elementsEqual("uploadImage")){
              uploadImageForRegionUtility(call,result: result)
          }else if(call.method.elementsEqual("deleteImage")){
              deleteImage(call,result: result)
          }else if(call.method.elementsEqual("listFiles")){
              listFiles(call,result: result)
          }
      }

      public func nameGenerator() -> String{
          let date = Date()
          let formatter = DateFormatter()
          formatter.dateFormat = "ddMMyyyy"
          let result = formatter.string(from: date)
          return "IMG" + result + String(Int64(date.timeIntervalSince1970 * 1000)) + "jpeg"
      }


    @objc lazy var transferUtility = {
        AWSS3TransferUtility.default()
    }()

    // use AWS Transfer Utility
    func uploadImageForRegionUtility(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        let arguments = call.arguments as? NSDictionary
        let imagePath = arguments!["filePath"] as? String
        let bucket = arguments!["bucket"] as? String
        let identity = arguments!["identity"] as? String
        let fileName = arguments!["imageName"] as? String
        let region = arguments!["region"] as? String
        let subRegion = arguments!["subRegion"] as? String


        let image    = UIImage(contentsOfFile: imagePath!)
        var imageAmazonUrl = ""
        let completionHandler : AWSS3TransferUtilityUploadCompletionHandlerBlock? =
            { (task, error) -> Void in

                if ((error) != nil)
                {
                  print("Upload failed")

                  result("failed")
                  return
                }
                else
                {
                  print("File uploaded successfully")
                  imageAmazonUrl = "https://s3-" + subRegion! +  ".amazonaws.com/\(fileName!)"
                  print("✅ Upload successed (\(imageAmazonUrl))")

                  result(imageAmazonUrl)
                  return
                }
            }

        
        guard let data = image!.jpegData(compressionQuality: 0.5) else { return  }

        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: AWSRegionType.regionTypeForString(regionString: region!),
            identityPoolId: identity!)
        let configuration = AWSServiceConfiguration(
            region: AWSRegionType.regionTypeForString(regionString: subRegion!),
            credentialsProvider: credentialsProvider)
        
    AWSServiceManager.default().defaultServiceConfiguration = configuration
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in DispatchQueue.main.async(execute: {
                // Do something e.g. Update a progress bar.
            })
        }

    AWSS3TransferUtility.default().uploadData(
        data,
        bucket: bucket!,
        key: fileName!,
        contentType: "image/jpg",
        expression: expression) { task, error in
            DispatchQueue.main.async {
                completionHandler!(task, error)
            }
            print("Success")

        }.continueWith { task -> AnyObject? in
            if let error = task.error {
                DispatchQueue.main.async {
                    completionHandler!(task.result!, error)
                }
            }
            return nil
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

          print("region " + region!)
          print("subregion " + subRegion!)
          print("bucket " + bucket!)

          var imageAmazonUrl = ""
          let fileUrl = NSURL(fileURLWithPath: imagePath!)

          let uploadRequest = AWSS3TransferManagerUploadRequest()
          uploadRequest?.bucket = bucket
          uploadRequest?.key = fileName


        var contentType = "image/jpeg"
        if(contentTypeParam != nil &&
            contentTypeParam!.count > 0){
            contentType = contentTypeParam!
        }

        if(contentTypeParam == nil || contentTypeParam!.count == 0 &&  fileName!.contains(".")){
                       var index = fileName!.lastIndex(of: ".")
                       index = fileName!.index(index!, offsetBy: 1)
                       if(index != nil){
                           let extention = String(fileName![index!...])
                           print("extension"+extention);
                           if(extention.lowercased().contains("png") ||
                           extention.lowercased().contains("jpg") ||
                               extention.lowercased().contains("jpeg") ){
                               contentType = "image/"+extention
                           }else{

                            if(extention.lowercased().contains("pdf")){
                                contentType = "application/pdf"
                                }else{
                                contentType = "application/*"
                                }

                           }

                       }
                   }

          uploadRequest?.contentType = contentType

          uploadRequest?.body = fileUrl as URL

          uploadRequest?.acl = .publicReadWrite


          let credentialsProvider = AWSCognitoCredentialsProvider(
              regionType: AWSRegionType.regionTypeForString(regionString: region!),
              identityPoolId: identity!)
          let configuration = AWSServiceConfiguration(
              region: AWSRegionType.regionTypeForString(regionString: subRegion!),
              credentialsProvider: credentialsProvider)
          
          AWSServiceManager.default().defaultServiceConfiguration = configuration

          AWSS3TransferManager.default().upload(uploadRequest!).continueWith { (task) -> AnyObject? in
              if let error = task.error {
                  print("❌ Upload failed (\(error))")
              }

              if task.result != nil {
                  imageAmazonUrl = "https://s3-" + subRegion! +  ".amazonaws.com/\(bucket!)/\(uploadRequest!.key!)"
                  print("✅ Upload successed (\(imageAmazonUrl))")
              } else {
                  print("❌ Unexpected empty result.")
              }
              result(imageAmazonUrl)
              return nil
          }
      }

      func deleteImage(_ call: FlutterMethodCall, result: @escaping FlutterResult){
          let arguments = call.arguments as? NSDictionary
          let bucket = arguments!["bucket"] as? String
          let identity = arguments!["identity"] as? String
          let fileName = arguments!["imageName"] as? String
          let region = arguments!["region"] as? String
          let subRegion = arguments!["subRegion"] as? String


          if(region != nil && subRegion != nil){
              initRegions(region: region!, subRegion: subRegion!)
          }

          let credentialsProvider = AWSCognitoCredentialsProvider(
              regionType: region1,
              identityPoolId: identity!)
          let configuration = AWSServiceConfiguration(
              region: subRegion1,
              credentialsProvider: credentialsProvider)
          AWSServiceManager.default().defaultServiceConfiguration = configuration

          AWSS3.register(with: configuration!, forKey: "defaultKey")
          let s3 = AWSS3.s3(forKey: "defaultKey")
          let deleteObjectRequest = AWSS3DeleteObjectRequest()
          deleteObjectRequest?.bucket = bucket // bucket name
          deleteObjectRequest?.key = fileName // File name
          s3.deleteObject(deleteObjectRequest!).continueWith { (task:AWSTask) -> AnyObject? in
              if let error = task.error {
                  print("Error occurred: \(error)")
                  result("Error occurred: \(error)")
                  return nil
              }
              print("image deleted successfully.")
              result("image deleted successfully.")
              return nil
          }


      }

      func listFiles(_ call: FlutterMethodCall, result: @escaping FlutterResult){
          let arguments = call.arguments as? NSDictionary
          let bucket = arguments!["bucket"] as? String
          let identity = arguments!["identity"] as? String
          let filePrefix = arguments!["prefix"] as? String
          let region = arguments!["region"] as? String
          let subRegion = arguments!["subRegion"] as? String


          if(region != nil && subRegion != nil){
              initRegions(region: region!, subRegion: subRegion!)
          }

          let credentialsProvider = AWSCognitoCredentialsProvider(
              regionType: AWSRegionType.regionTypeForString(regionString: region!),
              identityPoolId: identity!)
          let configuration = AWSServiceConfiguration(
              region: AWSRegionType.regionTypeForString(regionString: subRegion!),
              credentialsProvider: credentialsProvider)
          AWSServiceManager.default().defaultServiceConfiguration = configuration

          AWSS3.register(with: configuration!, forKey: "defaultKey")

          let s3 = AWSS3.s3(forKey: "defaultKey")
          let listRequest = AWSS3ListObjectsRequest()
          listRequest?.bucket = bucket // bucket name
          listRequest?.prefix = filePrefix // File prefix

          s3.listObjects(listRequest!).continueWith { (task:AWSTask) -> AnyObject? in
              if let error = task.error {
                  print("Error occurred: \(error)")
                  result("Error occurred: \(error)")
                  return nil
              }

              let keys = task.result?.contents!.map({ $0.key })
              result(keys)
              return nil
          }

      }

      public func initRegions(region:String,subRegion:String){
          region1 = getRegion(name: region)
          subRegion1 = getRegion(name: subRegion)
      }

      public func getRegion( name:String ) -> AWSRegionType{

          if(name == "US_EAST_1"){
              return AWSRegionType.USEast1
          }else if(name == "AP_SOUTHEAST_1"){
              return AWSRegionType.APSoutheast1
          }else if(name == "US_EAST_2"){
              return AWSRegionType.USEast2
          }else if(name == "EU_WEST_1"){
              return AWSRegionType.EUWest1
          }else if(name == "CA_CENTRAL_1"){
              return AWSRegionType.CACentral1
          }else if(name == "CN_NORTH_1"){
              return AWSRegionType.CNNorth1
          } else if(name == "CN_NORTHWEST_1"){
              return AWSRegionType.CNNorthWest1
          }else if(name == "EU_CENTRAL_1"){
              return AWSRegionType.EUCentral1
          } else if(name == "EU_WEST_2"){
              return AWSRegionType.EUWest2
          }else if(name == "EU_WEST_3"){
              return AWSRegionType.EUWest3
          } else if(name == "SA_EAST_1"){
              return AWSRegionType.SAEast1
          } else if(name == "US_WEST_1"){
              return AWSRegionType.USWest1
          }else if(name == "US_WEST_2"){
              return AWSRegionType.USWest2
          } else if(name == "AP_NORTHEAST_1"){
              return AWSRegionType.APNortheast1
          } else if(name == "AP_NORTHEAST_2"){
              return AWSRegionType.APNortheast2
          } else if(name == "AP_SOUTHEAST_1"){
              return AWSRegionType.APSoutheast1
          }else if(name == "AP_SOUTHEAST_2"){
              return AWSRegionType.APSoutheast2
          } else if(name == "AP_SOUTH_1"){
              return AWSRegionType.APSouth1
          }else if(name == "ME_SOUTH_1"){
            return AWSRegionType.MESouth1
          }

          return AWSRegionType.Unknown

      }
}
