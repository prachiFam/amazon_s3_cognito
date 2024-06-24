//
//  ImageData.swift
//  amazon_s3_cognito
//
//  Created by Paras mac on 11/10/21.
//

import Foundation

class ImageData:Decodable{

    var filePath: String
    var fileName: String
    var uniqueId: String
    var contentType: String?
    var imageUploadFolder: String?


    init(filePath:String,fileName:String,uniqueId:String,contentType:String?,imageFolderInBucket:String?) {
        self.filePath = filePath
        self.fileName = fileName
        self.uniqueId = uniqueId
        self.contentType = contentType
        self.imageUploadFolder = imageFolderInBucket
    }


    var isUploadInProgress: Bool = false
    var isUploadError: Bool = false
    var state : String = "INITIALIZED"
    var amazonImageUrl: String? = nil
    var progress: Double? = 0
    var failureReason: String?
}
