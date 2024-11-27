variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "the cidr of the vpc"
  type        = string
}

variable "public_subnet_documentDB_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "DocumentDB_sg" {
  description = "The ID of the presentation security group for instances"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "mydatabase14121414"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  default     = "Moamen"
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  default     = "moamen146"
  # sensitive   = true
}
