terraform {
  backend "s3" {
    bucket = "constellationlabs-tf"
    key = "splunk"
    region = "us-west-1"
  }
}
