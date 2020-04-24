terraform {
  backend "s3" {
    bucket = "constellationlabs-tf"
    key = "network"
    region = "us-west-1"
  }
}
