terraform {
  backend "s3" {
    bucket = "constellationlabs-terraform"
    key = "block-explorer-api"
    region = "us-west-1"
  }
}
