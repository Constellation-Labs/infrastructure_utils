package org.contellation.handler.input

import better.files.File
import org.constellation.consensus.StoredSnapshot
import org.contellation.handler.serializer.Serializer
import org.mockito.ArgumentMatchersSugar
import org.scalatest.{FunSuite, Matchers}

class S3HandlerTest extends FunSuite with ArgumentMatchersSugar with Matchers {

  private val snapshotFolder: String = "src/test/resources/snapshot"

  test("should load and deserialize snapshots") {
    val parsed = File(snapshotFolder).list.toSeq
      .map(s => Serializer.deserializeCast[StoredSnapshot](s.byteArray))
      .toList

    parsed.size shouldBe 1
    parsed.head.isInstanceOf[StoredSnapshot] shouldBe true
  }
}
