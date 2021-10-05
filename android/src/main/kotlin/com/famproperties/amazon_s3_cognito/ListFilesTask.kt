package com.famproperties.amazon_s3_cognito

import android.os.AsyncTask
import com.amazonaws.services.s3.AmazonS3Client
import com.amazonaws.services.s3.model.S3ObjectSummary

class ListFilesTask(private val s3: AmazonS3Client, private val bucket: String, private val prefix: String?, private val onListFilesCompleteListener: AwsRegionHelper.OnListFilesCompleteListener) : AsyncTask<Void, Void, List<S3ObjectSummary>>() {

    private var s3ObjList: List<S3ObjectSummary>? = null

    override fun doInBackground(vararg inputs: Void): List<S3ObjectSummary>? {
        // Queries files in the bucket from S3.
        if (prefix.isNullOrBlank()) {
            s3ObjList = s3.listObjects(bucket)?.getObjectSummaries()
        } else {
            s3ObjList = s3.listObjects(bucket, prefix)?.getObjectSummaries()
        }
        return s3ObjList
    }

    override fun onPostExecute(result: List<S3ObjectSummary>?) {
        result?.map { it.key }?.let { onListFilesCompleteListener.onListFiles(it) }
    }

}