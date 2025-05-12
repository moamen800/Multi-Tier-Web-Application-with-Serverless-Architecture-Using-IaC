variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "the cidr of the vpc"
  type        = string
}

variable "private_subnets_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "DocumentDB_sg_id" {
  description = "The ID of the presentation security group for instances"
  type        = string
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

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "db.t3.medium"
}