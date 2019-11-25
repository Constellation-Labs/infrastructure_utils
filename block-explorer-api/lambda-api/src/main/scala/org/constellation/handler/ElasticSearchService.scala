package org.constellation.handler

import com.sksamuel.elastic4s.ElasticDsl.{search, termQuery, _}
import com.sksamuel.elastic4s.http.JavaClient
import com.sksamuel.elastic4s.requests.searches.SearchResponse
import com.sksamuel.elastic4s.{ElasticClient, ElasticProperties, Response}
import org.constellation.handler.mapper.SourceExtractor
import org.constellation.handler.schema.Transaction

class ElasticSearchService(sourceExtractor: SourceExtractor) {

  private final val HOST: String =
    "http://vpc-es-block-explorer-2ubbjlfih5nnvuli64w76jbja4.us-west-1.es.amazonaws.com:80"
  private final val INDEX: String = "transactions"

  val client = ElasticClient(JavaClient(ElasticProperties(HOST)))

  def findTransaction(id: String): Seq[Transaction] = {
    val response = client.execute {
      search(INDEX).query(termQuery("hash", id))
    }.await

    sourceExtractor.extractTransactionsEsResult(response.body.getOrElse("")).getOrElse(Seq.empty)
  }
}
