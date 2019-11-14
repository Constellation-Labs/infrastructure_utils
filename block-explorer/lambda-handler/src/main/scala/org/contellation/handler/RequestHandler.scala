package org.contellation.handler

import org.contellation.handler.input.SQSHandler

object RequestHandler {

  def main(args: Array[String]): Unit = {
    println("Request Handler Application : Start")
    val sqsHandler: SQSHandler = new SQSHandler

    while (true) {

      try {
        println("Request Handler Application : Receive New Snapshots")
        val s: List[(String, String)] = sqsHandler.receiveNewSnapshots()
        print(s)
      } catch {
        case e: Throwable => println(e.getMessage)
      }

    }

  }
}
