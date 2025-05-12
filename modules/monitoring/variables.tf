variable "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  type        = list(string)
}

# variable "private_subnet_ids" {
#   description = "List of Private Subnet IDs"
#   type        = list(string)
# }

variable "Monitoring_sg_id" {
  description = "Security group ID for the presentation application load balancer"
  type        = string
}

variable "image_id" {
  description = "The AMI ID to use for the instances"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}
