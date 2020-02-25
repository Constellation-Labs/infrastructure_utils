variable "aws_region" {
  type = string
  default = "us-west-1"
}

variable "env" {
  type = string
  default = "dev"
}

variable "cl-vpc-id" {
  type = string
}

variable "cl-subnet-id" {
  type = string
}

variable "cl-sg-id" {
  type = string
}
