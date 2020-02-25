terraform {
  backend "s3" {
    bucket = "constellationlabs-terraform"
    key = "block_explorer"
    region = "us-west-1"
  }
}
