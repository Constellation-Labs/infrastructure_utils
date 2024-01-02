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

variable "cl-subnet-ids" {
  type = set(string)
}

variable "opensearch_instance-type" {
  type    = string
  default = "m6g.large.search"
}

variable "opensearch_instance-count" {
  type    = number
  default = 1
}

variable "opensearch_dedicated-master-count" {
  type    = number
  default = 0
}

variable "opensearch_dedicated-master-type" {
  type    = string
  default = "r5g.large.search"
}

variable "opensearch_zone-awareness-enabled" {
  type    = bool
  default = true
}

variable "opensearch_disk-size" {
  type    = string
  default = "200"
}

variable "create_iam_service_linked_role" {
  type        = string
  default     = "true"
  description = "true/false if should create opensearch service linked role"
}
