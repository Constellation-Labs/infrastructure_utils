package org.contellation.handler

import com.amazonaws.services.lambda.runtime.events.{APIGatewayProxyResponseEvent, S3Event}
import com.amazonaws.services.lambda.runtime.{Context, RequestHandler}
import com.amazonaws.services.s3.AmazonS3ClientBuilder
import com.amazonaws.services.s3.event.S3EventNotification
import com.amazonaws.services.s3.model.S3Object
import org.apache.commons.io.IOUtils
import org.slf4j.LoggerFactory

class LambdaHandler extends RequestHandler[S3Event, Unit] {

  private val LOG = LoggerFactory.getLogger(this.getClass)

  override def handleRequest(event: S3Event, context: Context): Unit = {
    event.getRecords.forEach(record => {
      try {
        val parsed = parseObject(downloadObjectFromAws(extractBucketName(record), extractObjectKey(record)))
        LOG.info(s"Object parsed $parsed")
      } catch {
        case exception: Exception => LOG.error(s"Error : ${exception.getMessage}")
      }
    })

    new APIGatewayProxyResponseEvent().setStatusCode(200)
  }

  private def extractBucketName(record: S3EventNotification.S3EventNotificationRecord): String =
    record.getS3.getBucket.getName

  private def extractObjectKey(record: S3EventNotification.S3EventNotificationRecord): String =
    record.getS3.getObject.getKey

  private def downloadObjectFromAws(bucketName: String, objectKey: String): S3Object =
    AmazonS3ClientBuilder.standard().build().getObject(bucketName, objectKey)

  private def parseObject(s3Object: S3Object) =
    IOUtils.toByteArray(s3Object.getObjectContent)
//    IOUtils.toByteArray(s3Object.getObjectContent).asInstanceOf[StoredSnapshot]

}
