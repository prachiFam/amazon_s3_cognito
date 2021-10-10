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

    public fun sendToStream(imageData:ImageData){
        sink?.success(imageData)
    }
}