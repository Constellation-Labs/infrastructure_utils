package org.constellation.handler

import com.amazonaws.services.lambda.runtime.events.{APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent}
import com.amazonaws.services.lambda.runtime.{Context, RequestHandler}
import io.circe.Decoder
import io.circe.generic.semiauto._
import org.constellation.handler.mapper.SourceExtractor
import org.constellation.handler.model.TransactionRequest
import sttp.client._

import scala.collection.JavaConverters._

object Handler extends RequestHandler[APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent] {

  implicit val transactionRequestEncoder: Decoder[TransactionRequest] = deriveDecoder[TransactionRequest]

  private final val HOST: String = "vpc-es-block-explorer-2ubbjlfih5nnvuli64w76jbja4.us-west-1.es.amazonaws.com"

  private val sourceExtractor: SourceExtractor = new SourceExtractor
  private val elasticSearchService: ElasticSearchService = new ElasticSearchService(sourceExtractor)

  override def handleRequest(input: APIGatewayProxyRequestEvent, context: Context): APIGatewayProxyResponseEvent = {
    val id = input.getQueryStringParameters.get("id")
    elasticSearchService.findTransaction(id) match {
      case Nil  => errorResponse("Cannot get transactions", 400)
      case list => successResponse(sourceExtractor.transactionsToJson(list).toString(), 200)
    }
  }

  private def checkConnectionToEs(): Boolean = {
    implicit val backend: SttpBackend[Identity, Nothing, NothingT] = HttpURLConnectionBackend()
    basicRequest.get(uri"$HOST").send().code.isSuccess
  }

  private def successResponse(body: String, statusCode: Integer = 200) =
    new APIGatewayProxyResponseEvent()
      .withStatusCode(200)
      .withHeaders(
        Map(
          "Content-Type" -> "text/json"
        ).asJava
      )
      .withBody(body)

  private def errorResponse(error: String, statusCode: Integer) =
    new APIGatewayProxyResponseEvent()
      .withStatusCode(statusCode)
      .withHeaders(
        Map(
          "Content-Type" -> "text/json"
        ).asJava
      )
      .withBody(s""" {"error": "$error"} """)
}
