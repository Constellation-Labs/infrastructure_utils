package org.constellation.handler.schema

case class Snapshot(
  hash: String,
  checkpointBlocks: Seq[String]
)
