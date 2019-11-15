package org.contellation.handler.input

import better.files.File
import org.constellation.consensus.StoredSnapshot
import org.contellation.handler.serializer.Serializer
import org.scalatest.FunSuite

class S3HandlerTest extends FunSuite {

  private val snapshotFolder: String = "src/test/resources/snapshot"

  test("should load and deserializer snapshots") {
    val s = File(snapshotFolder).list.toSeq
      .map(s => Serializer.deserializeCast[StoredSnapshot](s.byteArray))
    println(s)
  }
}
