variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Map of public subnets by availability zone"
  type        = map(string)
}

variable "private_subnets" {
  description = "Map of private subnets by availability zone"
  type        = map(string)
}