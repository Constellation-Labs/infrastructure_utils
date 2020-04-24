terraform {
  backend "s3" {
    bucket = "constellationlabs-tf"
    key = "block_explorer_api"
    region = "us-west-1"
  }
}
