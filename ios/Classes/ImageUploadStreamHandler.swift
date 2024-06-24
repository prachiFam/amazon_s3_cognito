//
//  ImageUploadListener.swift
//  amazon_s3_cognito
//
//  Created by Paras mac on 11/10/21.
//
import Flutter

class ImageUploadStreamHandler:NSObject, FlutterStreamHandler{

    private var eventSink: FlutterEventSink?

    func addImageUploadResult(imageData:ImageData) {

        let data: [String: Any?] = [
            "filePath" : imageData.filePath,
            "fileName" : imageData.fileName,
            "uniqueId" : imageData.uniqueId,
            "isUploadError" : imageData.isUploadError,
            "state" : imageData.state,
            "amazonImageUrl" : imageData.amazonImageUrl ,
            "progress" : imageData.progress,
            "failureReason":imageData.failureReason,
            "imageUploadFolder":imageData.imageUploadFolder]

        if(self.eventSink != nil){
            self.eventSink!(data)
        }

    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {

        self.eventSink = events
        return nil

    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {

        eventSink = nil
        return nil
    }



}

