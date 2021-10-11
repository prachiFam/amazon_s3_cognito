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
                              imageUploadResult:@escaping  (String)->()){
        
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
        
        AWSS3TransferManager.default().upload(uploadRequest!).continueWith { (task) -> AnyObject? in
            if let error = task.error {
                
                imageUploadResult("❌ Upload failed (\(error))")
                print("❌ Upload failed (\(error))")
            }
            
            
            if task.result != nil {
                
                //                        imageAmazonUrl = "https://s3-" + self.subRegion1.stringValue +  ".amazonaws.com/\(bucket!)/\(uploadRequest!.key!)"
                //
                imageAmazonUrl = AWSS3.default().configuration.endpoint.url.description + "/\(bucket!)/\(uploadRequest!.key!)"
                
                print("✅ Upload successed (\(imageAmazonUrl))")
                
                
                
                imageUploadResult(imageAmazonUrl)
                
            } else {
                imageUploadResult("❌ Upload failed (Unexpected empty result.)")
                print("❌ Unexpected empty result.")
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
