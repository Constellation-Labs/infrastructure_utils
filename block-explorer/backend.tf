terraform {
  backend "s3" {
    bucket = "constellationlabs-tf"
    key    = "block_explorer"
    region = "us-west-1"
  }
}
