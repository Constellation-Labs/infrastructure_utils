package org.contellation.handler

import org.contellation.handler.input.{S3Handler, SQSHandler}

object RequestHandler {

  def main(args: Array[String]): Unit = {
    println("Request Handler Application : Start")
    val sqsHandler: SQSHandler = new SQSHandler
    val s3Handler: S3Handler = new S3Handler

    while (true) {

      try {
        println("Request Handler Application : Receive New Snapshots")
        val r: List[(String, String)] = sqsHandler.receiveNewSnapshots()
        println(r)
        val s = s3Handler.getSnapshots(r)
        println(s)
      } catch {
        case e: Throwable => println(e.getMessage)
      }

    }

  }
}
