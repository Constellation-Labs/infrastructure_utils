terraform {
  backend "s3" {
    bucket = "constellationlabs-tf"
    key    = "ec2-cluster"
    region = "us-west-1"
  }
}
