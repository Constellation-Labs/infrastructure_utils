terraform {
  required_providers {
    splunk = {
      source = "splunk/splunk"
      version = "1.3.7"
    }
  }
}

provider "splunk" {
  url = "${var.splunk_ip}:8089"
  username = var.username
  password = var.password
  insecure_skip_verify = true
}
