variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "app_version" {
  type    = string
  default = "1.0.0"
}

locals {
  common_tags = {
    Environment = "example_03"
    Name        = "example_03_django_app"
  }
}
