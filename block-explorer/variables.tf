variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "cl-vpc-id" {
  type = string
}

variable "cl-vpc-cidr-block" {
  type = string
}

variable "cl-subnet-id" {
  type = string
}

variable "cl-network-interface-id" {
  type = string
}

variable "bucket-name" {
  type    = string
  default = "constellationlabs-block-explorer"
}

variable "opensearch_instance-type" {
  type    = string
  default = "m6g.large.search"
}

variable "opensearch_instance-count" {
  type    = number
  default = 1
}

variable "opensearch_disk-size" {
  type    = string
  default = "200"
}

variable "handler_instance-type" {
  type    = string
  default = "t2.micro"
}

variable "create_iam_service_linked_role" {
  type        = string
  default     = "true"
  description = "true/false if should create opensearch service linked role"
}