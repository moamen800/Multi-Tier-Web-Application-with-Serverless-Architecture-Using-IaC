####################################### CloudFront Distribution Output #######################################
# Outputs to provide key details for the CloudFront distribution and WAF Web ACL association.
output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.cdn.domain_name
  description = "The domain name of the CloudFront distribution"
}

output "cloudfront_distribution_arn" {
  value       = aws_cloudfront_distribution.cdn.arn
  description = "The ARN of the CloudFront distribution"
}

##############################################  WAF Output  ##############################################
output "WAF_web_acl" {
  description = "The ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.WAF_presentation_acl.arn # Retrieves the ARN for reference or for connecting other resources
}