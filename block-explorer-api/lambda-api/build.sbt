organization := "org.constellation"
name := "block-explorer-api-lambda"
version := "1.0.0"
scalaVersion := "2.12.9"

val AwsLambdaJavaCoreVersion = "1.2.0"
val AwsLambdaJavaEventsVersion = "2.2.2"
val CirceVersion = "0.12.3"
val KindProjectorVersion = "0.10.3"
val ScalaCheckVersion = "1.14.2"
val ScalaTestVersion = "3.0.8"

// format: off
libraryDependencies ++= Seq(
  "com.amazonaws"                   % "aws-lambda-java-core"        % AwsLambdaJavaCoreVersion,
  "com.amazonaws"                   % "aws-lambda-java-events"      % AwsLambdaJavaEventsVersion,
  "io.circe"                        %% "circe-core"                 % CirceVersion,
  "io.circe"                        %% "circe-generic"              % CirceVersion,
  "io.circe"                        %% "circe-parser"               % CirceVersion,
  // Test dependencies
  "org.scalacheck"                  %% "scalacheck"                 % ScalaCheckVersion % Test,
  "org.scalatest"                   %% "scalatest"                  % ScalaTestVersion % Test
)

javacOptions ++= Seq(
  "-source", "1.8",
  "-target", "1.8",
  "-Xlint"
)
// format: on

addCompilerPlugin(
  ("org.typelevel" %% "kind-projector" % KindProjectorVersion).cross(CrossVersion.binary)
)

enablePlugins(ScalafmtPlugin, JavaAppPackaging)

// Note: This fixes error with sbt run not loading config properly
fork in run := true
