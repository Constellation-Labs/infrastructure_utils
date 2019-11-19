package org.contellation.handler.output

import sttp.client._

class ElasticSearchSender {

  implicit val backend: SttpBackend[Identity, Nothing, NothingT] = HttpURLConnectionBackend()

  private final val HOST: String = "vpc-es-block-explorer-2ubbjlfih5nnvuli64w76jbja4.us-west-1.es.amazonaws.com"
  private final val INDEX: String = "block-explorer-data"
  private final val SCHEMA: String = "snapshot"

  def sendToElasticSearch(id: String, objectToSend: String): Unit = {
    val request = basicRequest
      .put(uri"$HOST/$INDEX/$SCHEMA/$id")
      .body(objectToSend)
      .contentType("application/json")

    val response: Identity[Response[Either[String, String]]] = request.send()

    println(response)
  }
}
