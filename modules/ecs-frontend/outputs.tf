# Output ECS Cluster name
output "frontend_ecs_cluster_name" {
  value = aws_ecs_cluster.frontend_cluster.name
}

output "presentation_alb_dns_name" {
  description = "dns of the presentation_business_logic_alb"
  value       = aws_lb.presentation_alb.dns_name
}

output "presentation_alb_id" {
  description = "ID of the presentation_business_logic_alb"
  value       = aws_lb.presentation_alb.id
}