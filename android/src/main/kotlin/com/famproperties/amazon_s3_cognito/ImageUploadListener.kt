package com.famproperties.amazon_s3_cognito

import io.flutter.plugin.common.EventChannel

class ImageUploadListener: EventChannel.StreamHandler {

    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?){
        sink = null
    }

    fun sendToStream(imageData:ImageData){
        val imageDataHashMap: HashMap<String, Any?>
            =  hashMapOf(
                "filePath" to imageData.filePath,
                "fileName" to imageData.fileName,
                "uniqueId" to imageData.uniqueId,
                "isUploadError" to imageData.isUploadError,
                "state" to imageData.state,
                "amazonImageUrl" to imageData.amazonImageUrl,
                "progress" to imageData.progress,
                "imageUploadFolder" to imageData.imageUploadFolder)

        sink?.success(imageDataHashMap)
    }
}