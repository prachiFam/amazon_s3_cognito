package com.famproperties.amazon_s3_cognito

class ImageData(var filePath: String, var fileName: String,var uniqueId: String, var imageUploadFolder: String?) {


    var isUploadInProgress: Boolean = false
    var isUploadError: Boolean = false
    var state : String = "INITIALIZED"
    var amazonImageUrl: String? = null
    var progress: Long? = 0

}