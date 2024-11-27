# Output ECS Cluster name
output "backend_ecs_cluster_name" {
  value = aws_ecs_cluster.backend_cluster.name
}

output "business_logic_alb_dns_name" {
  description = "The DNS of the business_logic_alb"
  value       = aws_lb.business_logic_alb.dns_name
}