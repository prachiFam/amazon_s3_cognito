//
//  AwsImageUploadHelper.swift
//  amazon_s3_cognito
//
//  Created by Paras mac on 11/10/21.
//

import Foundation
import AWSS3


class AwsImageUploadHelper{
    
    var region1:AWSRegionType = AWSRegionType.USEast1
    var subRegion1:AWSRegionType = AWSRegionType.EUWest1
    
    
    public func nameGenerator() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        let result = formatter.string(from: date)
        return "IMG" + result + String(Int64(date.timeIntervalSince1970 * 1000)) + "jpeg"
    }
    
    
    func uploadImageForRegion(imagePath:String?, bucket:String?,identity:String?,fileName:String?,
                              region:String?,subRegion:String?,
                              contentTypeParam:String?,
                              imageUploadResult:@escaping  (String)->())
    {


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

           var imageAmazonUrl = ""
           guard let fileUrl = URL(string: imagePath!) else {
               imageUploadResult("❌ Invalid file path")
               return
           }

           // Determine content type
           var contentType = "image/jpeg"
           if let contentTypeParam = contentTypeParam, !contentTypeParam.isEmpty {
               contentType = contentTypeParam
           } else if let fileName = fileName, fileName.contains(".") {
               let ext = fileName.split(separator: ".").last!.lowercased()
               if ["png", "jpg", "jpeg"].contains(ext) {
                   contentType = "image/\(ext)"
               } else if ext == "pdf" {
                   contentType = "application/pdf"
               } else {
                   contentType = "application/*"
               }
           }

           let expression = AWSS3TransferUtilityUploadExpression()
           expression.progressBlock = { (task, progress) in
               DispatchQueue.main.async {
                   // Update UI with progress
                   print("Upload progress: \(progress.fractionCompleted)")
               }
           }

           let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (task, error) in
               DispatchQueue.main.async {
                   if let error = error {
                       imageUploadResult("❌ Upload failed (\(error))")
                       print("❌ Upload failed (\(error))")
                   } else {
                       imageAmazonUrl = AWSS3.default().configuration.endpoint.url.description + "/\(bucket!)/\(fileName!)"
                       print("✅ Upload succeeded (\(imageAmazonUrl))")
                       imageUploadResult(imageAmazonUrl)
                   }
               }
           }

           let transferUtility = AWSS3TransferUtility.default()
           transferUtility.uploadFile(fileUrl,
                                    bucket: bucket!,
                                    key: fileName!,
                                    contentType: contentType,
                                    expression: expression,
                                    completionHandler: completionHandler).continueWith { (task) -> Any? in
               if let error = task.error {
                   print("Error: \(error)")
                   imageUploadResult("❌ Upload failed (\(error))")
                   print("❌ Upload failed (\(error))")
               }
               if let _ = task.result {
                   print("Upload Starting!")
               }
               return nil
           }

    }

    func deleteImage(bucket:String?,identity:String?,fileName:String?,
                     region:String?, subRegion:String?,
                     imageDeleteResult:@escaping  (String)->()){

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
                imageDeleteResult("Error occurred: \(error)")
                return nil
            }
            print("image deleted successfully.")
            imageDeleteResult("image deleted successfully.")
            return nil
        }
        
        
    }
    
    
    
    public func initRegions(region:String,subRegion:String){
        region1 = RegionHelper.getRegion(name: region)
        subRegion1 = RegionHelper.getRegion(name: subRegion)
    }
    
}
