package org.contellation.handler.model

case class Snapshot(hash: String, checkpointBlocks: Seq[String])
