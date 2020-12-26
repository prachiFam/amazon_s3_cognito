package com.famproperties.amazon_s3_cognito

import android.content.Context
import android.os.AsyncTask
import android.util.Log


import com.amazonaws.auth.CognitoCachingCredentialsProvider
import com.amazonaws.mobileconnectors.s3.transferutility.*
import com.amazonaws.regions.Region
import com.amazonaws.regions.Regions
import com.amazonaws.services.s3.AmazonS3Client
import com.amazonaws.services.s3.model.S3ObjectSummary
import java.io.File
import java.io.UnsupportedEncodingException


class AwsRegionHelper(private val context: Context,
                      private val BUCKET_NAME: String, private val IDENTITY_POOL_ID: String,
                      private val REGION: String, private val SUB_REGION: String) {

    private var transferUtility: TransferUtility
    private var nameOfUploadedFile: String? = null
    private var region1:Regions = Regions.DEFAULT_REGION
    private var subRegion1:Regions = Regions.DEFAULT_REGION


    init {

        initRegion()
        val credentialsProvider = CognitoCachingCredentialsProvider(context, IDENTITY_POOL_ID, region1)
        val amazonS3Client = AmazonS3Client(credentialsProvider)
        amazonS3Client.setRegion(com.amazonaws.regions.Region.getRegion(subRegion1))
        TransferNetworkLossHandler.getInstance(context.applicationContext)
        transferUtility = TransferUtility(amazonS3Client, context)
    }

    private val uploadedUrl: String
        get() = getUploadedUrl(nameOfUploadedFile)

    private fun getUploadedUrl(key: String?): String {
        return "https://s3-"+subRegion1.getName()+".amazonaws.com/"+BUCKET_NAME+"/"+key
        //return  ""+key
    }

    private fun initRegion(){

        region1 = getRegionFor(REGION)
        subRegion1 = getRegionFor(SUB_REGION)

    }

    @Throws(UnsupportedEncodingException::class)
    fun deleteImage(imageName: String, onUploadCompleteListener: OnUploadCompleteListener): String {

        initRegion()

        val credentialsProvider = CognitoCachingCredentialsProvider(context, IDENTITY_POOL_ID, region1)
        TransferNetworkLossHandler.getInstance(context.applicationContext)

        val amazonS3Client = AmazonS3Client(credentialsProvider)
        amazonS3Client.setRegion(com.amazonaws.regions.Region.getRegion(subRegion1))
        Thread(Runnable{
            amazonS3Client.deleteObject(BUCKET_NAME, imageName)
        }).start()
        onUploadCompleteListener.onUploadComplete("Success")
        return imageName

    }

    @Throws(UnsupportedEncodingException::class)
    fun uploadImage(image: File, imageName: String, onUploadCompleteListener: OnUploadCompleteListener): String {

        initRegion()

        val credentialsProvider = CognitoCachingCredentialsProvider(context, IDENTITY_POOL_ID, region1)
        TransferNetworkLossHandler.getInstance(context.applicationContext)

        val amazonS3Client = AmazonS3Client(credentialsProvider)
        amazonS3Client.setRegion(com.amazonaws.regions.Region.getRegion(subRegion1))
        transferUtility = TransferUtility(amazonS3Client, context)

        nameOfUploadedFile = imageName;

        val transferObserver = transferUtility.upload(BUCKET_NAME, nameOfUploadedFile, image)

        transferObserver.setTransferListener(object : TransferListener {
            override fun onStateChanged(id: Int, state: TransferState) {
                if (state == TransferState.COMPLETED) {
                    onUploadCompleteListener.onUploadComplete(getUploadedUrl(nameOfUploadedFile))
                }
                if (state == TransferState.FAILED ||  state == TransferState.WAITING_FOR_NETWORK) {
                    onUploadCompleteListener.onFailed()
                }
            }

            override fun onProgressChanged(id: Int, bytesCurrent: Long, bytesTotal: Long) {}
            override fun onError(id: Int, ex: Exception) {
                onUploadCompleteListener.onFailed()
                Log.e(TAG, "error in upload id [ " + id + " ] : " + ex.message)

            }
        })
        return uploadedUrl
    }

    fun listFiles(prefix: String?, onListFilesCompleteListener: OnListFilesCompleteListener) {

        initRegion()

        val credentialsProvider = CognitoCachingCredentialsProvider(context, IDENTITY_POOL_ID, Regions.fromName(REGION))
        val amazonS3Client = AmazonS3Client(credentialsProvider, Region.getRegion(REGION))

        ListFilesTask(amazonS3Client, BUCKET_NAME, prefix, onListFilesCompleteListener).execute()
    }

    @Throws(UnsupportedEncodingException::class)
    fun clean(filePath: String): String {
        return filePath.replace("[^.A-Za-z0-9]".toRegex(), "")
    }

    interface OnUploadCompleteListener {
        fun onUploadComplete(imageUrl: String)
        fun onFailed()
    }

    interface OnListFilesCompleteListener {
        fun onListFiles(output: List<String>)
    }

    companion object {
        private val TAG = AwsRegionHelper::class.java.simpleName
        private const val URL_TEMPLATE = "https://s3.amazonaws.com/%s/%s"
    }

    private fun  getRegionFor(name:String):Regions{

        if(name == "US_EAST_1" || name == "us-east-1"){
            return Regions.US_EAST_1
        }else if(name == "AP_SOUTHEAST_1"){
            return Regions.AP_SOUTHEAST_1
        }else if(name == "US_EAST_2"){
            return Regions.US_EAST_2
        }else if(name == "EU_WEST_1"){
            return Regions.EU_WEST_1
        }else if(name == "CA_CENTRAL_1"){
            return Regions.CA_CENTRAL_1
        }else if(name == "CN_NORTH_1"){
            return Regions.CN_NORTH_1
        } else if(name == "CN_NORTHWEST_1"){
            return Regions.CN_NORTHWEST_1
        }else if(name == "EU_CENTRAL_1"){
            return Regions.EU_CENTRAL_1
        } else if(name == "EU_WEST_2"){
            return Regions.EU_WEST_2
        }else if(name == "EU_WEST_3"){
            return Regions.EU_WEST_3
        } else if(name == "SA_EAST_1"){
            return Regions.SA_EAST_1
        } else if(name == "US_WEST_1"){
            return Regions.US_WEST_1
        }else if(name == "US_WEST_2"){
            return Regions.US_WEST_2
        } else if(name == "AP_NORTHEAST_1"){
            return Regions.AP_NORTHEAST_1
        } else if(name == "AP_NORTHEAST_2"){
            return Regions.AP_NORTHEAST_2
        } else if(name == "AP_SOUTHEAST_1"){
            return Regions.AP_SOUTHEAST_1
        }else if(name == "AP_SOUTHEAST_2"){
            return Regions.AP_SOUTHEAST_2
        } else if(name == "AP_SOUTH_1"){
            return Regions.AP_SOUTH_1
        }else if(name == "ME_SOUTH_1"){
            return Regions.ME_SOUTH_1
        }else if(name == "AP_EAST_1"){
            return Regions.AP_EAST_1
        }else if(name == "EU_NORTH_1"){
            return Regions.EU_NORTH_1
        }else if(name == "US_GOV_EAST_1"){
            return Regions.US_GOV_EAST_1
        }else if(name == "us-gov-west-1"){
            return Regions.GovCloud
        }

        return Regions.DEFAULT_REGION

    }

    private inner class ListFilesTask : AsyncTask<Void, Void, List<S3ObjectSummary>> {
        private val s3: AmazonS3Client
        private val bucket: String
        private val prefix: String?
        private val onListFilesCompleteListener: OnListFilesCompleteListener

        private var s3ObjList: List<S3ObjectSummary>? = null

        constructor(s3: AmazonS3Client, bucket: String, prefix: String?, onListFilesCompleteListener: OnListFilesCompleteListener) : super () {
            this.s3 = s3
            this.bucket = bucket
            this.prefix = prefix
            this.onListFilesCompleteListener = onListFilesCompleteListener
        }

        override fun doInBackground(vararg inputs: Void): List<S3ObjectSummary>? {
            // Queries files in the bucket from S3.
            if (prefix.isNullOrBlank()) {
                s3ObjList = s3?.listObjects(bucket)?.getObjectSummaries()
            } else {
                s3ObjList = s3?.listObjects(bucket, prefix)?.getObjectSummaries()
            }
            return s3ObjList
        }

        override fun onPostExecute(result: List<S3ObjectSummary>?) {
            result?.map { it.key }?.let { onListFilesCompleteListener.onListFiles(it) }
        }

    }
}