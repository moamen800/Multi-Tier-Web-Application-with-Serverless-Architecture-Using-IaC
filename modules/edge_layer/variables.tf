variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
variable "presentation_alb_dns_name" {
  description = "DNS of the presentation_alb"
  type        = string
}

variable "presentation_alb_id" {
  description = "ID of the presentation_alb"
  type        = string
}
