###################################### AWS Region Variable #######################################
variable "aws_region" {
  description = "AWS region for resource deployment"
}

# ####################################### Web ALB Variable #######################################
variable "presentation_alb_dns_name" {
  description = "dns of the presentation_alb"
  type        = string
}

variable "presentation_alb_id" {
  description = "dns of the presentation_alb"
  type        = string
}
