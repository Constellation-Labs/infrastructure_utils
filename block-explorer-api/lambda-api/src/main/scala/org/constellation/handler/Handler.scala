package org.constellation.handler

import scala.collection.JavaConverters._
import com.amazonaws.services.lambda.runtime.{Context, RequestHandler}
import com.amazonaws.services.lambda.runtime.events.{APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent}

object Handler extends RequestHandler[APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent] {

  override def handleRequest(input: APIGatewayProxyRequestEvent, context: Context): APIGatewayProxyResponseEvent = {
    def log(message: String): Unit = context.getLogger.log(message)

    log("-- Received new request --")
    log(s"Method : ${input.getHttpMethod}")
    log(s"Proxy path : ${input.getPath}")
    log(s"Proxy parameters : ${input.getPathParameters}")

    new APIGatewayProxyResponseEvent()
      .withStatusCode(200)
      .withHeaders(
        Map(
          "Content-Type" -> "text/raw"
        ).asJava
      )
      .withBody("OK")
  }
}
