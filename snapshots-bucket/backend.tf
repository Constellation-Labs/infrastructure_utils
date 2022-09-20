terraform {
  backend "s3" {
    bucket = "constellationlabs-tf"
    key    = "snapshots-bucket"
    region = "us-west-1"
  }
}
