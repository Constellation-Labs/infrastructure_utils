package org.contellation.handler.serializer

import com.twitter.chill.{KryoPool, ScalaKryoInstantiator}
import org.constellation.serializer.ConstellationKryoRegistrar

object Serializer extends {

  def guessThreads: Int = {
    val cores = Runtime.getRuntime.availableProcessors
    val GUESS_THREADS_PER_CORE = 4
    GUESS_THREADS_PER_CORE * cores
  }

  val kryoPool: KryoPool = KryoPool.withBuffer(
    guessThreads,
    new ScalaKryoInstantiator()
      .setRegistrationRequired(true)
      .withRegistrar(new ConstellationKryoRegistrar()),
    32,
    1024 * 1024 * 100
  )

  def serializeAnyRef(anyRef: AnyRef): Array[Byte] =
    kryoPool.toBytesWithClass(anyRef)

  def deserializeCast[T](message: Array[Byte]): T =
    kryoPool.fromBytes(message).asInstanceOf[T]
}
