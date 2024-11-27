# The VPC ID to associate the resources with
variable "vpc_id" {
  description = "The VPC ID"
  type        = string # A string type to hold the ID of the VPC
}

variable "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  type        = list(string)
}

variable "business_logic_alb_sg_id" {
  description = "Security group ID for the presentation business_logiclication load balancer"
  type        = string # A string type to hold the ID of the security group associated with the ALB
}

variable "business_logic_sg_id" {
  description = "The ID of the presentation security group for instances"
  type        = string # A string type to hold the security group ID for the EC2 instances
}

# Variable for the business_logiclication name
variable "business_logic_name" {
  description = "The name of the business_logiclication container"
  type        = string
  default     = "Backend-container"
}

# Variable for the image URI
variable "image_uri" {
  description = "The URI of the Docker image for the business_logiclication"
  type        = string
  default     = "307946672811.dkr.ecr.us-east-1.amazonaws.com/backend-mern:latest"
}

# Variable for ECS execution role ARN
variable "ecs_execution_role_arn" {
  description = "The ARN of the ECS execution role"
  type        = string
}

# Variable for ECS task role ARN
variable "ecs_task_role_arn" {
  description = "The ARN of the ECS task role"
  type        = string
}


variable "documentdb_cluster_endpoint" {
  description = "The primary endpoint of the Amazon DocumentDB Cluster."
  type        = string
}