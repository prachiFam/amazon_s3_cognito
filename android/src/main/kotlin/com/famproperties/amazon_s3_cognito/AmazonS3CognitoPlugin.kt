package com.famproperties.amazon_s3_cognito

import android.app.Activity
import android.content.Context
import com.google.gson.JsonObject
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.service.ServiceAware
import io.flutter.embedding.engine.plugins.service.ServicePluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

import org.jetbrains.annotations.NotNull
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.UnsupportedEncodingException

class AmazonS3CognitoPlugin :FlutterPlugin,MethodCallHandler, ActivityAware , ServiceAware {

    private lateinit var channel : MethodChannel
    private lateinit var eventChannel : EventChannel

    private var awsRegionHelper: AwsRegionHelper? = null
    private var  awsMultiImageRegionHelper:AwsMultipleFileUploadHelper? = null

    private lateinit var context: Context
    private lateinit var activity: Activity

    private  lateinit var imageUploadListener:ImageUploadListener


    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "amazon_s3_cognito")
            val instance = AmazonS3CognitoPlugin()
            instance.activity = registrar.activity()
            channel.setMethodCallHandler(instance)


            val eventChannel = EventChannel(registrar.messenger(), "amazon_s3_cognito_images_upload_steam")


        }
    }


    override fun onMethodCall(call: MethodCall, result: Result) {
        val filePath = call.argument<String>("filePath")
        val bucket = call.argument<String>("bucket")
        val identity = call.argument<String>("identity")
        val fileName = call.argument<String>("imageName")
        val region = call.argument<String>("region")
        val subRegion = call.argument<String>("subRegion")
        val prefix = call.argument<String>("prefix")
        val imageDataListJson = call.argument<String>("imageDataList")
        var needProgressUpdateAlso = call.argument<Boolean>("needProgressUpdateAlso")



        if (call.method.equals("uploadImage") ) {
            if(filePath == null){
                return  result.error("file path cannot be empty","error",1)
            }else{

                var imageUploadFolder = call.argument<String>("imageUploadFolder")

                val file = File(filePath)
                try {
                    awsRegionHelper = AwsRegionHelper(context, bucket!!, identity!!, region!!, subRegion!!)
                    awsRegionHelper!!.uploadImage(file, fileName!!,imageUploadFolder, object : AwsRegionHelper.OnUploadCompleteListener {
                        override fun onFailed() {
                            System.out.println("\n❌ upload failed")
                            try{
                                result.success("Failed")
                            }catch (e:Exception){

                            }

                        }

                        override fun onUploadComplete(@NotNull imageUrl: String) {
                            System.out.println("\n✅ upload complete: $imageUrl")
                            result.success(imageUrl)
                        }
                    })
                } catch (e: UnsupportedEncodingException) {
                    e.printStackTrace()
                }
            }

        } else if (call.method.equals("deleteImage")) {
            try {

                var imageUploadFolder = call.argument<String>("imageUploadFolder")


                awsRegionHelper = AwsRegionHelper(context, bucket!!, identity!!, region!!, subRegion!!)
                awsRegionHelper!!.deleteImage(fileName!!, imageUploadFolder,object : AwsRegionHelper.OnUploadCompleteListener{

                    override fun onFailed() {
                        System.out.println("\n❌ delete failed")
                        try{
                            result.success("Failed")
                        }catch (e:Exception){

                        }

                    }

                    override fun onUploadComplete(@NotNull imageUrl: String) {
                        System.out.println("\n✅ delete complete: $imageUrl")

                        try{
                            result.success(imageUrl)
                        }catch (e:Exception){

                        }
                    }
                })
            } catch (e: UnsupportedEncodingException) {
                e.printStackTrace()
            }

        } else if (call.method.equals("uploadImages")) {
            try {
                val list:ArrayList<ImageData> = ArrayList()
                if(imageDataListJson != null){
                    val jsonArray = JSONArray(imageDataListJson)
                    for (jsonIndex in 0 until jsonArray.length()) {
                        val jsonObject: JSONObject = jsonArray.getJSONObject(jsonIndex)
                        val path:String = jsonObject.getString("filePath")
                        val nameOfFile:String = jsonObject.getString("fileName")
                        val uniqueKey:String =  jsonObject.getString("uniqueId")
                        val imageUploadFolder:String =  jsonObject.getString("imageUploadFolder")
                        val imageData = ImageData(path,nameOfFile,uniqueKey,imageUploadFolder)
                        list.add(imageData)
                    }
                }
                if(needProgressUpdateAlso == null){
                    needProgressUpdateAlso = true;
                }
                awsMultiImageRegionHelper = AwsMultipleFileUploadHelper(
                        context,
                        bucket!!,identity!!, region!!, subRegion!!,list,imageUploadListener,needProgressUpdateAlso )

                awsMultiImageRegionHelper?.uploadImages()
                result.success("Uploaded started successfully")

            } catch (e: UnsupportedEncodingException) {
                e.printStackTrace()
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "amazon_s3_cognito")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "amazon_s3_cognito_images_upload_steam")
        imageUploadListener = ImageUploadListener()
        eventChannel.setStreamHandler(imageUploadListener)

        //Factory.setup(this, flutterPluginBinding.binaryMessenger)
        context = flutterPluginBinding.applicationContext

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        imageUploadListener.onCancel(1)
        eventChannel.setStreamHandler(null)


    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivity() {

    }

    override fun onAttachedToService(binding: ServicePluginBinding) {
        context = binding.service.applicationContext
    }

    override fun onDetachedFromService() {

    }
}
