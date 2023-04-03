terraform {
  backend "s3" {
    bucket = "constellationlabs-tf"
    key = "logs-bucket"
    region = "us-west-1"
  }
}
