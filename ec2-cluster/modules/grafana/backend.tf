terraform {
  backend "s3" {
    bucket = "constellationlabs-tf"
    key    = "tessellation-grafana"
    region = "us-west-1"
  }
}
