package org.contellation.handler.input

import com.amazonaws.services.sqs.model.{DeleteMessageRequest, Message, ReceiveMessageRequest}
import com.amazonaws.services.sqs.{AmazonSQS, AmazonSQSClientBuilder}
import io.circe.Json
import io.circe.parser.parse

import scala.collection.JavaConverters._
import scala.util.Try

class SQSHandler {

  private val queueUrl = "https://sqs.us-west-1.amazonaws.com/150340915792/s3-event-block-explorer-queue"

  private val SQSClient: AmazonSQS = {
    AmazonSQSClientBuilder.defaultClient()
  }

  def receiveNewSnapshots(): List[(String, String)] =
    receiveMessage()
      .flatMap(message => Try(extractMessage(message)).toOption)
      .flatten

  private def extractMessage(message: Message): List[(String, String)] = {
    val json = parse(message.getBody).right.get
    val jsonRecords = json.hcursor.downField("Records").values.get

    jsonRecords
      .map(record => (extractBucketName(record), extractObjectKey(record)))
      .toList
  }

  private def extractBucketName(record: Json): String =
    record.hcursor
      .downField("s3")
      .downField("bucket")
      .downField("name")
      .as[String]
      .right
      .get

  private def extractObjectKey(record: Json): String =
    record.hcursor
      .downField("s3")
      .downField("object")
      .downField("key")
      .as[String]
      .right
      .get

  private def receiveMessage(): List[Message] = {
    val messageRequest: ReceiveMessageRequest = new ReceiveMessageRequest(queueUrl)
      .withWaitTimeSeconds(10)
      .withMaxNumberOfMessages(10)

    val receivedMessages: List[Message] = SQSClient.receiveMessage(messageRequest).getMessages.asScala.toList
    receivedMessages.foreach(m => deleteMessage(m))

    receivedMessages
  }

  private def deleteMessage(message: Message) = {
    val messageDeleteRequest = new DeleteMessageRequest(queueUrl, message.getReceiptHandle)
    SQSClient.deleteMessage(messageDeleteRequest)
  }
}
