terraform {
  backend "s3" {
    bucket = "constellationlabs-tf"
    key = "development-cluster"
    region = "us-west-1"
  }
}
