//
//  AwsMultiImageUploadHelper.swift
//  amazon_s3_cognito
//
//  Created by Paras mac on 11/10/21.
//

import Foundation
import AWSS3


typealias progressBlock = (_ progress: Double) -> Void //2
typealias completionBlock = (_ response: Any?, _ error: Error?) -> Void //3

class AwsMultiImageUploadHelper{
    

    var bucketName:String = ""
    var identityPoolId:String = ""
    var needFileProgressUpdateAlso = false

    init(region:String,subRegion:String,
         identity:String,bucketName:String,
         needFileProgressUpdateAlso:Bool?) {

        let region1 = RegionHelper.getRegion(name: region)
        let subRegion1 = RegionHelper.getRegion(name: subRegion)
        self.identityPoolId = identity
        self.bucketName = bucketName

        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: region1,
            identityPoolId: identityPoolId)
        let configuration = AWSServiceConfiguration(
            region: subRegion1,
            credentialsProvider: credentialsProvider)

        AWSServiceManager.default().defaultServiceConfiguration = configuration


        if(needFileProgressUpdateAlso != nil){
            self.needFileProgressUpdateAlso = needFileProgressUpdateAlso!
        }
    }


    func uploadMultipleImages(imagesData:[ImageData],imageUploadSreamHelper:ImageUploadStreamHandler){

        for imageDataObj in imagesData{

            let fileUrl = URL(fileURLWithPath: imageDataObj.filePath)

            var contentType:String = "image/jpeg"
            if(imageDataObj.contentType != nil &&
                imageDataObj.contentType!.count > 0){
                contentType = imageDataObj.contentType!
            }

            if(imageDataObj.contentType == nil || imageDataObj.contentType?.count == 0 &&  imageDataObj.fileName.contains(".")){

                contentType = getContentTypeFromFile(fileName: imageDataObj.fileName)
            }


            uploadfile(filePath: imageDataObj.filePath, fileName: imageDataObj.fileName,folderToUploadTo: imageDataObj.imageUploadFolder, contenType: contentType, progress: {[weak self] ( uploadProgress) in

                guard self != nil else { return }


                if((self?.needFileProgressUpdateAlso) != nil && self?.needFileProgressUpdateAlso == true){

                    imageDataObj.state = "FILE PROGRESS"

                    imageDataObj.progress = Double(uploadProgress)

                    imageUploadSreamHelper.addImageUploadResult(imageData: imageDataObj)
                }



            } , completion: {[weak self] (uploadedFileUrl, error) in

                guard self != nil else { return }
                if let finalPath = uploadedFileUrl as? String { // 3
                    imageDataObj.state = "COMPLETED"
                    imageDataObj.amazonImageUrl = uploadedFileUrl as? String
                    imageUploadSreamHelper.addImageUploadResult(imageData: imageDataObj)

                    print("Uploaded file url: " + finalPath)
                } else {
                    imageDataObj.isUploadError = true
                    imageDataObj.state = "FAILURE"
                    imageDataObj.progress = 0
                    imageDataObj.failureReason = error?.localizedDescription

                    imageUploadSreamHelper.addImageUploadResult(imageData: imageDataObj)


                    print("\(String(describing: error?.localizedDescription))") // 4
                }
            })
        }

    }

    func getContentTypeFromFile(fileName:String) -> String {
        var contentType = "image/jpeg"

        if(fileName.contains(".")){
            var index = fileName.lastIndex(of: ".")
            index = fileName.index(index!, offsetBy: 1)
            if(index != nil){
                let extention = String(fileName[index!...])

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
        return contentType
    }


    //MARK:- AWS file upload
        // fileUrl :  file local path url
        // fileName : name of file, like "myimage.jpeg" "video.mov"
        // contenType: file MIME type
        // progress: file upload progress, value from 0 to 1, 1 for 100% complete
        // completion: completion block when uplaoding is finish, you will get S3 url of upload file here
    private func uploadfile(filePath: String, fileName: String, folderToUploadTo:String?, contenType: String, progress: progressBlock?, completion: completionBlock?) {

        var key = fileName

        if(folderToUploadTo != nil){
            key = folderToUploadTo! + fileName
        }

            // Upload progress block
            let expression = AWSS3TransferUtilityUploadExpression()


            expression.progressBlock = {(task, awsProgress) in
                guard let uploadProgress = progress else { return }
                DispatchQueue.main.async {
                    print(awsProgress.fractionCompleted.description)

                    uploadProgress(awsProgress.fractionCompleted)
                }
            }
            // Completion block
            var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
            completionHandler = { (task, error) -> Void in
                if error == nil {
                    let url = AWSS3.default().configuration.endpoint.url
                    let publicURL = url?.appendingPathComponent(self.bucketName).appendingPathComponent(key)
                    print("Uploaded to:\(String(describing: publicURL))")
                    if let completionBlock = completion {
                        completionBlock(publicURL?.absoluteString, nil)
                    }
                } else {
                    if let completionBlock = completion {
                        print("error is :\(String(describing: error.debugDescription))")
                        completionBlock(nil, error)
                    }
                }
            }
            // Start uploading using AWSS3TransferUtility
            let awsTransferUtility = AWSS3TransferUtility.default()


            let data:Data? = FileManager.default.contents(atPath: filePath)

            if(data != nil){

                print("image upload will start")



                awsTransferUtility.uploadData(data!, bucket: bucketName, key: key, contentType: contenType, expression: expression, completionHandler: completionHandler).continueWith { (task) -> Any? in
                    if let error = task.error {

                        if let completionBlock = completion {
                            print("error is :\(String(describing: error.localizedDescription))")
                            completionBlock(nil, error)
                        }


                        print("error is: \(error.localizedDescription)")
                    }
                    if let _ = task.result {
                        // your uploadTask
                    }
                    return nil
                }
            }


        }
    
}
