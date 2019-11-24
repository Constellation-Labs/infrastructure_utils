package org.constellation.blockexplorer.handler

import org.constellation.blockexplorer.handler.config.ConfigLoader
import org.constellation.blockexplorer.handler.input.{S3Handler, SQSHandler}
import org.constellation.blockexplorer.handler.mapper.{
  SQSMessageJsonExtractor,
  SnapshotJsonMapper,
  StoredSnapshotMapper
}
import org.constellation.blockexplorer.handler.output.ElasticSearchSender
import org.constellation.blockexplorer.handler.serializer.{KryoSerializer, Serializer}

object RequestHandler {

  def main(args: Array[String]): Unit = {
    println("Request Handler : Init started")
    val configLoader: ConfigLoader = new ConfigLoader
    val serializer: Serializer = new KryoSerializer
    val sqsMessageJsonExtractor: SQSMessageJsonExtractor = new SQSMessageJsonExtractor
    val snapshotJsonMapper: SnapshotJsonMapper = new SnapshotJsonMapper
    val storedSnapshotMapper: StoredSnapshotMapper = new StoredSnapshotMapper

    val sqsHandler: SQSHandler = new SQSHandler(configLoader, sqsMessageJsonExtractor)
    val s3Handler: S3Handler = new S3Handler(serializer)
    val esSender: ElasticSearchSender = new ElasticSearchSender(configLoader, snapshotJsonMapper, storedSnapshotMapper)
    println("Request Handler : Init finished")

    while (true) {
      try {
        println("Try to receive new snapshots")
        val r: List[(String, String)] = sqsHandler.receiveNewSnapshots()
        println(s"Received snapshot SQS : ${r.size}")
        val s = s3Handler.getSnapshots(r)
        println(s"Downloaded snapshot : ${s.size}")
        s.foreach(storedSnapshot => esSender.mapAndSendToElasticSearch(storedSnapshot))
        println(s"Sending finished")
      } catch {
        case e: Throwable =>
          println(e.getMessage)
      }
    }
  }

}
