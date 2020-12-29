package com.famproperties.amazon_s3_cognito

import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import org.jetbrains.annotations.NotNull
import java.io.File
import java.io.UnsupportedEncodingException

class AmazonS3CognitoPlugin private constructor(private val context: Context) : MethodCallHandler {
    private var awsHelper: AwsHelper? = null
    private var awsRegionHelper: AwsRegionHelper? = null


    companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "amazon_s3_cognito")
        val instance = AmazonS3CognitoPlugin(registrar.context())
        channel.setMethodCallHandler(instance)
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


      if (call.method.equals("uploadImageToAmazon")) {
          val file = File(filePath)
          try {
              awsHelper = AwsHelper(context, object : AwsHelper.OnUploadCompleteListener{
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
              },  bucket!!, identity!!)
              awsHelper!!.uploadImage(file)
          } catch (e: UnsupportedEncodingException) {
              e.printStackTrace()
          }

      } else if (call.method.equals("uploadImage")) {
          val file = File(filePath)
          try {
              awsRegionHelper = AwsRegionHelper(context, bucket!!, identity!!, region!!, subRegion!!)
              awsRegionHelper!!.uploadImage(file, fileName!!, object : AwsRegionHelper.OnUploadCompleteListener {
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

      } else if (call.method.equals("deleteImage")) {
          try {
              awsRegionHelper = AwsRegionHelper(context, bucket!!, identity!!, region!!, subRegion!!)
              awsRegionHelper!!.deleteImage(fileName!!, object : AwsRegionHelper.OnUploadCompleteListener{

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

      } else if (call.method.equals("listFiles")) {
          try {
              awsRegionHelper = AwsRegionHelper(context, bucket!!, identity!!, region!!, subRegion!!)
              val files = awsRegionHelper!!.listFiles(prefix, object : AwsRegionHelper.OnListFilesCompleteListener {
                  override fun onListFiles(files: List<String>) {
                      System.out.println("\n✅ list complete: $files")
                      result.success(files)
                  }

              })
          } catch (e: UnsupportedEncodingException) {
              e.printStackTrace()
          }
      } else {
          result.notImplemented()
      }
  }
}
