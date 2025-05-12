variable "vpc_id" {
  description = "The ID of the VPC to associate the resources with"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for use with ALB or internet-facing services"
  type        = list(string)
}

variable "presentation_alb_sg_id" {
  description = "The security group ID for the Application Load Balancer (presentation layer)"
  type        = string
}

variable "presentation_sg_id" {
  description = "The security group ID for EC2 instances in the presentation layer"
  type        = string
}

variable "family_name_frontend" {
  description = "The ECS task definition family name for the frontend container"
  type        = string
  default     = "Frontend-Container"
}

variable "image_uri_frontend" {
  description = "The URI of the Docker image for the frontend service"
  type        = string
  default     = "307946672811.dkr.ecr.eu-west-1.amazonaws.com/frontend-mern:latest"
}

variable "ecs_execution_role_arn" {
  description = "The ARN of the ECS execution role used by ECS to pull images and write logs"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "The ARN of the ECS task role assumed by the frontend task to access AWS services"
  type        = string
}

variable "business_logic_alb_dns_name" {
  description = "The DNS name of the Application Load Balancer for the business logic layer"
  type        = string
}
