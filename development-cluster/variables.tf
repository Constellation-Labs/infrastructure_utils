variable "aws_region" {
  type = string
  default = "us-west-1"
}

variable "env" {
  type = string
  default = "dev"
}

variable "repositories" {
  type = map(object({ capacity=number }))
  default = {
    "l0-validator" = {
      capacity = 20
    },
    "l1-validator" = {
      capacity = 20
    },
    "snapshot-streaming" = {
      capacity = 20
    }
  }
}

variable "authorized_user_group" {
  type = string
  default = "Admin"
}
