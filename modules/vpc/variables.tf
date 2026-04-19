variable "region" {
  default = "us-east-1"
}

variable "environment" {
  default = "dev"
}

variable "main_cidr" {
  default = "10.0.0.0/16"
}
variable "public_subnet_1_cidr" {
  default = "10.0.1.0/24"
}
variable "public_subnet_2_cidr" {
  default = "10.0.2.0/24"
}
variable "private_subnet_1_cidr" {
  default = "10.0.3.0/24"
}
variable "private_subnet_2_cidr" {
  default = "10.0.4.0/24"
}

variable "destination_cidr" {
  default = "0.0.0.0/0"
}

data "aws_availability_zones" "available" {}

