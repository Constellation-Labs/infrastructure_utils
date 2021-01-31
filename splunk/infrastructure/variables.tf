variable "instance-type" {
  type = string
  default = "t2.micro"
}

variable "aws_region" {
  type = string
  default = "us-west-1"
}

variable "nodes" {
  type = set(object({ alias=string, cidr=string }))
}

variable "env" {
  type = string
  default = "dev"
}

//variable "cl-vpc-id" {
//  type = string
//}