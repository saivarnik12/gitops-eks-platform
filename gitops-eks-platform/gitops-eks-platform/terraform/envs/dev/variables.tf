variable "aws_region" {
  default = "ap-south-1"
}

variable "environment" {
  default = "dev"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "node_instance_types" {
  default = ["t3.medium"]
}

variable "desired_nodes" {
  default = 2
}

variable "min_nodes" {
  default = 1
}

variable "max_nodes" {
  default = 4
}
