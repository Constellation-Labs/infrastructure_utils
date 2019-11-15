package org.contellation.handler.input

import com.amazonaws.services.s3.AmazonS3ClientBuilder
import com.amazonaws.services.s3.model.S3Object
import org.apache.commons.io.IOUtils
import org.constellation.consensus.StoredSnapshot
import org.contellation.handler.serializer.Serializer

import scala.util.Try

class S3Handler {

  private val S3Client = {
    AmazonS3ClientBuilder.defaultClient()
  }

  def getSnapshots(toDownload: List[(String, String)]): List[StoredSnapshot] = {
    getListOfObjects(toDownload).flatMap(s => Try(parseToSnapshot(s)).toOption)
  }

  private def parseToSnapshot(s3Object: S3Object): StoredSnapshot = {
    val objectBytes: Array[Byte] =
      IOUtils.toByteArray(s3Object.getObjectContent)
    Serializer.deserializeCast[StoredSnapshot](objectBytes)
  }

  private def getListOfObjects(
    toDownload: List[(String, String)]
  ): List[S3Object] = {
    toDownload.flatMap(o => Try(getObject(o._1, o._2)).toOption)
  }

  private def getObject(bucketName: String, objectKey: String): S3Object = {
    S3Client.getObject(bucketName, objectKey)
  }
}
