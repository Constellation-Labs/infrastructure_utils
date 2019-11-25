package org.constellation.handler.mapper

import org.scalatest.{FunSuite, Matchers}

class SourceExtractorTest extends FunSuite with Matchers {

  val message: String = """{
    "took": 2,
    "timed_out": false,
    "_shards": {
      "total": 5,
      "successful": 5,
      "skipped": 0,
      "failed": 0
    },
    "hits": {
      "total": {
      "value": 1,
      "relation": "eq"
    },
      "max_score": 4.158883,
      "hits": [
    {
      "_index": "transactions",
      "_type": "_doc",
      "_id": "36545f85251a319e25d333072be52b9f05a7e5a6333c4a6e48040c167c5e5b99",
      "_score": 4.158883,
      "_source": {
      "hash": "36545f85251a319e25d333072be52b9f05a7e5a6333c4a6e48040c167c5e5b99",
      "amount": 0,
      "fee": 0,
      "isDummy": true,
      "lastTransactionRef": {
      "hash": "",
      "ordinal": 0
    },
      "snapshotHash": "0c3c5b967d78b6eee57fe840516e03dd62c6169e15f3863426fbc94c5c3c03ef",
      "checkpointBlock": "023422779e809f5f377e398fbb3b9df1814ba969e3fc99f83cf59f08ad185003"
    }
    }
      ]
    }
  }"""

  test("should extract source from message") {
    val sourceExtractor: SourceExtractor = new SourceExtractor
    val transactions = sourceExtractor.extractTransactionsEsResult(message)

    transactions.size shouldBe 1

    println(sourceExtractor.transactionsToJson(transactions.getOrElse(Seq.empty)))
  }
}
