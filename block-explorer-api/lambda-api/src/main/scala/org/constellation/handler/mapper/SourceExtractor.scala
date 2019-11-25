package org.constellation.handler.mapper

import io.circe.syntax._
import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import io.circe.parser.parse
import org.constellation.handler.schema.{CheckpointBlock, Height, LastTransactionRef, Snapshot, Transaction}

import scala.util.Try

class SourceExtractor {

  implicit val snapshotDecoder: Decoder[Snapshot] = deriveDecoder[Snapshot]
  implicit val checkpointDecoder: Decoder[CheckpointBlock] = deriveDecoder[CheckpointBlock]
  implicit val heightDecoder: Decoder[Height] = deriveDecoder[Height]
  implicit val transactionDecoder: Decoder[Transaction] = deriveDecoder[Transaction]
  implicit val lastTransactionRefDecoder: Decoder[LastTransactionRef] = deriveDecoder[LastTransactionRef]

  implicit val snapshotEncoder: Encoder[Snapshot] = deriveEncoder[Snapshot]
  implicit val checkpointEncoder: Encoder[CheckpointBlock] = deriveEncoder[CheckpointBlock]
  implicit val heightEncoder: Encoder[Height] = deriveEncoder[Height]
  implicit val transactionEncoder: Encoder[Transaction] = deriveEncoder[Transaction]
  implicit val lastTransactionRefEncoder: Encoder[LastTransactionRef] = deriveEncoder[LastTransactionRef]

  def extractTransactionsEsResult(doc: String): Option[Seq[Transaction]] =
    Try(extractTransactions(doc)).toOption

  private def extractTransactions(doc: String): Seq[Transaction] = {
    val json: Json = parse(doc).right.get
    val hits: Iterable[Json] = json.hcursor.downField("hits").downField("hits").values.get

    hits.map(_.hcursor.downField("_source").as[Transaction].right.get).toSeq
  }

  def transactionsToJson(transactions: Seq[Transaction]): Json =
    transactions.asJson
}
