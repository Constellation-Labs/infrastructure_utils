organization := "org.constellation"
name := "block-explorer-handler-lambda"
version := "1.0.0"
scalaVersion := "2.12.9"

val AwsLambdaJavaCoreVersion = "1.2.0"
val AwsLambdaJavaEventsVersion = "2.2.2"
val AwsJavaSdkS3 = "1.11.665"
val AwsJavaSdkSQS = "1.11.665"
val BetterFilesVersion = "3.8.0"
val CirceVersion = "0.12.3"
val CommonIOVersion = "2.6"
val KindProjectorVersion = "0.10.3"
val LogbackVersion = "1.2.3"
val MockitoVersion = "1.6.2"
val ScalaCheckVersion = "1.14.2"
val ScalaTestVersion = "3.0.8"
val Slf4jApiVersion = "1.7.25"
val SttpCoreVersion = "2.0.0-RC1"
val TwitterChillVersion = "0.9.3"
val TypesafeVersion = "1.4.0"

unmanagedJars in Runtime += file("constellation-assembly-1.0.12.jar")

// format: off
libraryDependencies ++= Seq(
  "com.amazonaws"                   % "aws-java-sdk-s3"             % AwsJavaSdkS3,
  "com.amazonaws"                   % "aws-java-sdk-sqs"            % AwsJavaSdkSQS,
  "com.amazonaws"                   % "aws-lambda-java-core"        % AwsLambdaJavaCoreVersion,
  "com.amazonaws"                   % "aws-lambda-java-events"      % AwsLambdaJavaEventsVersion,
  "com.github.pathikrit"            %% "better-files"               % BetterFilesVersion,
  "com.softwaremill.sttp.client"    %% "core"                       % SttpCoreVersion,
  "com.typesafe"                    % "config"                      % TypesafeVersion, 
  "com.twitter"                     %% "chill"                      % TwitterChillVersion,
  "commons-io"                      % "commons-io"                  % CommonIOVersion,
  "ch.qos.logback"                  % "logback-classic"             % LogbackVersion, 
  "io.circe"                        %% "circe-core"                 % CirceVersion,
  "io.circe"                        %% "circe-generic"              % CirceVersion,
  "io.circe"                        %% "circe-parser"               % CirceVersion,
  "org.slf4j"                       % "slf4j-api"                   % Slf4jApiVersion,
  // Test dependencies
  "org.mockito"                     %% "mockito-scala"              % MockitoVersion % Test,
  "org.mockito"                     %% "mockito-scala-cats"         % MockitoVersion % Test,
  "org.scalacheck"                  %% "scalacheck"                 % ScalaCheckVersion % Test,
  "org.scalatest"                   %% "scalatest"                  % ScalaTestVersion % Test
)

javacOptions ++= Seq(
  "-source", "1.8",
  "-target", "1.8",
  "-Xlint"
)

scalacOptions ++= {
    val defaultOpts = Seq(
        "-deprecation",
        "-encoding", "utf-8",
        "-explaintypes",
        "-feature",
        "-language:existentials",
        "-language:experimental.macros",
        "-language:higherKinds",
        "-language:implicitConversions",
        "-unchecked",
        "-Xcheckinit",
        "-Xfatal-warnings",
        "-Xfuture",
        "-Xlint:adapted-args",
        "-Xlint:by-name-right-associative",
        "-Xlint:constant",
        "-Xlint:delayedinit-select",
        "-Xlint:doc-detached",
        "-Xlint:inaccessible",
        "-Xlint:infer-any",
        "-Xlint:missing-interpolator",
        "-Xlint:nullary-override",
//        "-Xlint:nullary-unit",
        "-Xlint:option-implicit",
        "-Xlint:package-object-classes",
        "-Xlint:poly-implicit-overload",
        "-Xlint:private-shadow",
        "-Xlint:stars-align",
        "-Xlint:type-parameter-shadow",
        "-Xlint:unsound-match",
        "-Yno-adapted-args",
        "-Ypartial-unification",
//        "-Ywarn-dead-code",
        "-Ywarn-extra-implicit",
        "-Ywarn-infer-any",
        "-Ywarn-inaccessible",
        "-Ywarn-numeric-widen",
        "-Ywarn-nullary-override",
//        "-Ywarn-nullary-unit",
        "-Ywarn-unused:implicits",
        "-Ywarn-unused:imports",
        "-Ywarn-unused:locals",
        "-Ywarn-unused:params",
        "-Ywarn-unused:patvars",
        "-Ywarn-unused:privates",
        "-Ywarn-value-discard"
    )
    defaultOpts
}
// format: on

addCompilerPlugin(
  ("org.typelevel" %% "kind-projector" % KindProjectorVersion)
    .cross(CrossVersion.binary)
)

enablePlugins(ScalafmtPlugin, JavaAppPackaging)

// Filter out compiler flags to make the repl experience functional...
val badConsoleFlags = Seq("-Xfatal-warnings", "-Ywarn-unused:imports")
scalacOptions in (Compile, console) ~= (_.filterNot(
  badConsoleFlags.contains(_)
))

// Note: This fixes error with sbt run not loading config properly
fork in run := true

assemblyMergeStrategy in assembly := {
  case PathList("META-INF", xs @ _*) => MergeStrategy.discard
  case x                             => MergeStrategy.first
}

Test / classLoaderLayeringStrategy := ClassLoaderLayeringStrategy.Flat
