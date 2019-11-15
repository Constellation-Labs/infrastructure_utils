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
    println("Start getting snapshots from S3")
    getListOfObjects(toDownload).flatMap(s => Try(parseToSnapshot(s)).toOption)
  }

  private def parseToSnapshot(s3Object: S3Object): StoredSnapshot = {
    println(s"To deserialize : $s3Object")
    val objectBytes: Array[Byte] =
      IOUtils.toByteArray(s3Object.getObjectContent)
    Serializer.deserializeCast[StoredSnapshot](objectBytes)
  }

  private def getListOfObjects(
    toDownload: List[(String, String)]
  ): List[S3Object] = {
    println(s"To download : $toDownload")
    toDownload.flatMap(o => Try(getObject(o._1, o._2)).toOption)
  }

  private def getObject(bucketName: String, objectKey: String): S3Object = {
    println(s"Getting from S3 : $bucketName : $objectKey")
    S3Client.getObject(bucketName, objectKey)
  }
}
