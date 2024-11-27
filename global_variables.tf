####################################### Provider Variables #######################################
# Configuration for AWS provider
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1" # Default region
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  default     = "default" # Default profile
}