####################################### Security Group Outputs #######################################
output "presentation_alb_sg_id" {
  description = "ID of the presentation business_logiclication load balancer security group"
  value       = aws_security_group.presentation_alb_sg.id
}

output "presentation_sg_id" {
  description = "The ID of the presentation security group for instances"
  value       = aws_security_group.presentation_sg.id
}

output "business_logic_alb_sg_id" {
  description = "ID of the presentation business_logiclication load balancer security group"
  value       = aws_security_group.business_logic_alb_sg.id
}

output "business_logic_sg_id" {
  description = "The ID of the presentation security group for instances"
  value       = aws_security_group.business_logic_sg.id
}

output "DocumentDB_sg_id" {
  description = "The ID of the presentation security group for instances"
  value       = aws_security_group.DocumentDB_sg.id
}

output "Monitoring_sg_id" {
  description = "The ID of the Monitoring security group for instances"
  value       = aws_security_group.monitoring_sg.id
}
