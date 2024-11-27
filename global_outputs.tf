output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.edge_layer.cloudfront_domain_name

}

output "presentation_alb_dns_name" {
  description = "The DNS of the presentation_alb"
  value       = module.ecs-frontend.presentation_alb_dns_name
}

output "business_logic_alb_dns_name" {
  description = "The DNS of the business_logic_servers_alb"
  value       = module.ecs-backend.business_logic_alb_dns_name
}
