package org.contellation.handler.model

case class Snapshot(
  hash: String,
  checkpointBlocks: Seq[String],
  checkpoint: Seq[Checkpoint]
)

case class Checkpoint(
  height: Height,
  transactions: Seq[Transaction]
)

case class Height(
  min: Long,
  max: Long
)

case class Transaction(
  hash: String,
  amount: Long,
  fee: Long,
  isDummy: Boolean,
  lastTransactionRef: LastTransactionRef
)

case class LastTransactionRef(
  hash: String,
  ordinal: Long
)
