package org.contellation.handler

import io.circe.generic.semiauto._
import io.circe.syntax._
import org.constellation.consensus.StoredSnapshot
import org.contellation.handler.input.{S3Handler, SQSHandler}
import org.contellation.handler.model.Snapshot
import org.contellation.handler.output.ElasticSearchSender

object RequestHandler {

  def main(args: Array[String]): Unit = {
    println("Request Handler Application : Start")
    val sqsHandler: SQSHandler = new SQSHandler
    val s3Handler: S3Handler = new S3Handler
    val esSender: ElasticSearchSender = new ElasticSearchSender

    while (true) {

      try {
        println("Request Handler Application : Receive New Snapshots")
        val r: List[(String, String)] = sqsHandler.receiveNewSnapshots()
        val s = s3Handler.getSnapshots(r)
        println(s"DOWNLOADED SNAPSHOTS: ${s.size}")
        s.map(snap => {
          val e = prepareDataForElasticSearch(snap)
            .asJson(deriveEncoder[Snapshot])
          println(e.toString())
          esSender.sendToElasticSearch(e.hashCode().toString, e.toString())
        })

      } catch {
        case e: Throwable =>
          println(e.getMessage)
      }

    }
  }

  private def prepareDataForElasticSearch(
    storedSnapshot: StoredSnapshot
  ): Snapshot =
    Snapshot(
      storedSnapshot.snapshot.hash,
      storedSnapshot.snapshot.checkpointBlocks
    )
}
