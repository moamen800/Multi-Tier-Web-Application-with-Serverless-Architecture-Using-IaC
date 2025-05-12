variable "vpc_id" {
  description = "The ID of the VPC to associate all resources with"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where the resources will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for load balancers or public-facing services"
  type        = list(string)
}

variable "private_subnets_ids" {
  description = "List of private subnet IDs used for backend services or database subnet groups"
  type        = list(string)
}

variable "business_logic_alb_sg_id" {
  description = "The security group ID attached to the Application Load Balancer for the business logic layer"
  type        = string
}

variable "business_logic_sg_id" {
  description = "The security group ID attached to the EC2 instances handling the business logic"
  type        = string
}

variable "family_name_backend" {
  description = "The ECS task definition family name for the backend application"
  type        = string
}

variable "image_uri_backend" {
  description = "The URI of the Docker image for the backend service"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "The ARN of the ECS task execution role used by Fargate or ECS to pull images and log to CloudWatch"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "The ARN of the ECS task role assumed by the application task to access AWS services"
  type        = string
}

variable "documentdb_cluster_endpoint" {
  description = "The primary endpoint URL of the Amazon DocumentDB cluster"
  type        = string
}
