package com.famproperties.amazon_s3_cognito

import android.content.ContentValues.TAG
import android.content.Context

import android.util.Log
import com.amazonaws.auth.CognitoCachingCredentialsProvider
import com.amazonaws.mobileconnectors.s3.transferutility.*
import com.amazonaws.regions.Region
import com.amazonaws.regions.Regions
import com.amazonaws.services.s3.AmazonS3Client

import java.io.File

class AwsMultipleFileUploadHelper(private val context: Context,
                                  private val BUCKET_NAME: String, private val IDENTITY_POOL_ID: String,
                                  private val REGION: String, private val SUB_REGION: String, private var imagesData: List<ImageData>, private val imageUploadListener: ImageUploadListener, private var needProgressUpdateAlso:Boolean) {

    private var transferUtility: TransferUtility
    private var region1: Regions = Regions.DEFAULT_REGION
    private var subRegion1: Regions = Regions.DEFAULT_REGION



    init {
        initRegion()
        transferUtility =  getTransferUtility()

    }

    private fun getTransferUtility(): TransferUtility {
        //val awsConfiguration = AWSConfiguration(context)
        //awsConfiguration.
        val amazonS3Client = getAmazonS3Client()

        TransferNetworkLossHandler.getInstance(context.applicationContext)
        val transferOptions = TransferUtilityOptions()
        transferOptions.transferThreadPoolSize = 18

        return  TransferUtility.builder()
                .s3Client(amazonS3Client).
                transferUtilityOptions(transferOptions)
                .defaultBucket(BUCKET_NAME)
                .context(context)
                .build()
    }

    private fun getUploadedUrl(key: String): String {
        return "https://s3-"+subRegion1.getName()+".amazonaws.com/"+BUCKET_NAME+"/"+key
        //return  ""+key
    }

    private fun getAmazonS3Client(): AmazonS3Client {
        val credentialsProvider = CognitoCachingCredentialsProvider(context, IDENTITY_POOL_ID, region1)
        return AmazonS3Client(credentialsProvider, Region.getRegion(subRegion1))

    }

    private fun initRegion(){
        region1 = RegionHelper(REGION).getRegionName()
        subRegion1 = RegionHelper(SUB_REGION).getRegionName()
    }


    fun uploadImages(){
        TransferNetworkLossHandler.getInstance(context.applicationContext)

        for(imageData in imagesData){
            val file = File(imageData.filePath)

            var key = imageData.fileName

            if(imageData.imageUploadFolder != null){

                key = if(imageData.imageUploadFolder!!.endsWith("/")){
                    imageData.imageUploadFolder  + imageData.fileName
                }else{
                    "$imageData.imageUploadFolder /$imageData.fileName"
                }

            }

            val transferObserver = transferUtility.upload(BUCKET_NAME, key, file)
            imageData.isUploadInProgress = true
            transferObserver.setTransferListener(object : TransferListener {
                override fun onStateChanged(id: Int, state: TransferState) {
                    if (state == TransferState.COMPLETED) {
                        imageData.isUploadInProgress = false
                        imageData.amazonImageUrl = getUploadedUrl(key)
                        imageData.state = "COMPLETED"
                        imageUploadListener.sendToStream(imageData)

                    }
                    if (state == TransferState.FAILED ||  state == TransferState.WAITING_FOR_NETWORK) {
                        imageData.isUploadInProgress = false
                        imageData.isUploadError = true
                        imageData.state = "FAILED OR WAITING_FOR_NETWORK"
                        imageUploadListener.sendToStream(imageData)
                    }
                }

                override fun onProgressChanged(id: Int, bytesCurrent: Long, bytesTotal: Long) {

                    if(needProgressUpdateAlso){
                        imageData.state = "FILE PROGRESS"
                        imageData.progress = (bytesCurrent * 100)/bytesTotal

                        imageUploadListener.sendToStream(imageData)
                    }

                }
                override fun onError(id: Int, ex: Exception) {
                    imageData.isUploadError = true
                    imageData.state = "FAILURE"
                    imageData.progress = 0
                    imageUploadListener.sendToStream(imageData)
                    Log.e(TAG, "error in upload id [ " + id + " ] : " + ex.message)

                }
            })

        }
    }

}