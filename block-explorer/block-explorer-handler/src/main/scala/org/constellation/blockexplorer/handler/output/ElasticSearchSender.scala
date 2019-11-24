package org.constellation.blockexplorer.handler.output

import org.constellation.blockexplorer.handler.config.ConfigLoader
import org.constellation.blockexplorer.handler.mapper.{SnapshotJsonMapper, StoredSnapshotMapper}
import org.constellation.blockexplorer.schema.{CheckpointBlock, Snapshot, Transaction}
import org.constellation.consensus.StoredSnapshot
import sttp.client._

class ElasticSearchSender(
  configLoader: ConfigLoader,
  snapshotJsonMapper: SnapshotJsonMapper,
  storedSnapshotMapper: StoredSnapshotMapper
) {

  implicit val backend: SttpBackend[Identity, Nothing, NothingT] = HttpURLConnectionBackend()

  def mapAndSendToElasticSearch(storedSnapshot: StoredSnapshot): Unit = {
    val snapshotToSend = storedSnapshotMapper.mapSnapshot(storedSnapshot)
    val checkpointBlocks = storedSnapshotMapper.mapCheckpointBlock(storedSnapshot)
    val transactions = storedSnapshotMapper.mapTransaction(storedSnapshot)

    sendSnapshot(snapshotToSend.hash, snapshotToSend)
    checkpointBlocks.foreach(c => sendCheckpointBlock(c.hash, c))
    transactions.foreach(t => sendTransaction(t.hash, t))
  }

  private def sendSnapshot(id: String, snapshot: Snapshot) =
    sendToElasticSearch(
      id,
      configLoader.elasticsearchSnapshotsIndex,
      configLoader.elasticsearchSnapshotsMapping,
      snapshotJsonMapper.mapSnapshotToJson(snapshot).toString()
    )

  private def sendCheckpointBlock(id: String, checkpointBlock: CheckpointBlock) =
    sendToElasticSearch(
      id,
      configLoader.elasticsearchCheckpointBlocksIndex,
      configLoader.elasticsearchCheckpointBlocksMapping,
      snapshotJsonMapper.mapCheckpointBlockToJson(checkpointBlock).toString()
    )

  private def sendTransaction(id: String, transaction: Transaction) =
    sendToElasticSearch(
      id,
      configLoader.elasticsearchTransactionsIndex,
      configLoader.elasticsearchTransactionsMapping,
      snapshotJsonMapper.mapTransactionToJson(transaction).toString()
    )

  private def sendToElasticSearch(id: String, index: String, schema: String, objectToSend: String) =
    basicRequest
      .put(uri"${configLoader.elasticsearchUrl}/$index/$schema/$id")
      .body(objectToSend)
      .contentType("application/json")
      .send()
}
