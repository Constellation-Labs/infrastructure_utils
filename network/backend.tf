terraform {
  backend "s3" {
    bucket = "constellationlabs-terraform"
    key = "network"
    region = "us-west-1"
  }
}
