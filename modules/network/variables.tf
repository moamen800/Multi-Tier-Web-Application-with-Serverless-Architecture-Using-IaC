####################################### VPC Variables #######################################
# Configuration for VPC and subnets

# VPC name
variable "vpc_name" {
  description = "The name of the VPC"
  default     = "multi-tier-vpc"
}

# CIDR block for the VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16" # IP range for the VPC, allowing up to 65536 IP addresses
}

# Public subnets with their availability zones and IP ranges
variable "public_subnets" {
  description = "Map of public subnets by availability zone"
  default = {
    "us-east-1a" = "10.0.1.0/24" # Public subnet 1 in us-east-1a
    "us-east-1b" = "10.0.2.0/24" # Public subnet 2 in us-east-1b
  }
}

# Public subnets with their availability zones and IP ranges
variable "public_subnets_documentDB" {
  description = "Map of public subnets by availability zone"
  default = {
    "us-east-1a" = "10.0.100.0/24" # Public subnet 1 in us-east-1a
    "us-east-1b" = "10.0.200.0/24" # Public subnet 2 in us-east-1b
  }
}