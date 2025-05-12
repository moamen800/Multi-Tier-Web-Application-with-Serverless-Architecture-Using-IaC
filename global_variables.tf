variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
}

variable "image_id" {
  description = "The ID of the AMI to use"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for EC2 instances"
  type        = string
}

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

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "family_name_frontend" {
  description = "The name of the business_logiclication container"
  type        = string
  default     = "Frontend-Container"
}

# Variable for the image URI
variable "image_uri_frontend" {
  description = "The URI of the Docker image for the business_logiclication"
  type        = string
}


variable "family_name_backend" {
  description = "The name of the business_logiclication container"
  type        = string
}

# Variable for the image URI
variable "image_uri_backend" {
  description = "The URI of the Docker image for the business_logiclication"
  type        = string
}