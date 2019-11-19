package org.contellation.handler

import io.circe.Encoder
import io.circe.generic.semiauto._
import io.circe.syntax._
import org.constellation.consensus.StoredSnapshot
import org.contellation.handler.input.{S3Handler, SQSHandler}
import org.contellation.handler.model._
import org.contellation.handler.output.ElasticSearchSender

object RequestHandler {

  implicit val snapshotEncoder: Encoder[Snapshot] = deriveEncoder[Snapshot]
  implicit val checkpointEncoder: Encoder[Checkpoint] = deriveEncoder[Checkpoint]
  implicit val heightEncoder: Encoder[Height] = deriveEncoder[Height]
  implicit val transactionEncoder: Encoder[Transaction] = deriveEncoder[Transaction]
  implicit val lastTransactionRefEncoder: Encoder[LastTransactionRef] = deriveEncoder[LastTransactionRef]

  def main(args: Array[String]): Unit = {
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
          val e = prepareDataForElasticSearch(snap).asJson
          println(e.toString())
          esSender.sendToElasticSearch(e.hashCode().toString, e.toString())
        })

      } catch {
        case e: Throwable =>
          println(e.getMessage)
      }

    }
  }

  private def prepareDataForElasticSearch(storedSnapshot: StoredSnapshot): Snapshot = {
    val checkpoint: Seq[Checkpoint] = storedSnapshot.checkpointCache.map(c => {
      Checkpoint(
        c.height.map(h => Height(h.min, h.max)).getOrElse(Height(-1, -1)),
        c.checkpointBlock
          .map(
            b =>
              b.transactions.map(
                t =>
                  Transaction(
                    t.hash,
                    t.amount,
                    t.fee.getOrElse(0),
                    t.isDummy,
                    LastTransactionRef(t.lastTxRef.hash, t.lastTxRef.ordinal)
                  )
              )
          )
          .getOrElse(Seq.empty[Transaction])
      )
    })

    Snapshot(
      storedSnapshot.snapshot.hash,
      storedSnapshot.snapshot.checkpointBlocks,
      checkpoint
    )
  }
}
