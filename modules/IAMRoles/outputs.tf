########################################### Outputs ###########################################

# Output the ECS execution role ARN
output "ecs_execution_role_arn" {
  description = "The ARN of the ECS execution role"
  value       = aws_iam_role.ecs_execution_role.arn
}

# Output the ECS task role ARN
output "ecs_task_role_arn" {
  description = "The ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

# Output the ARN of the custom ECR policy
output "ecr_policy_arn" {
  description = "The ARN of the custom ECR policy"
  value       = aws_iam_policy.ecs_execution_policy.arn
}

# Output the ARN of the AmazonEC2ContainerRegistryReadOnly managed policy
output "ecr_readonly_policy_arn" {
  description = "The ARN of the AmazonEC2ContainerRegistryReadOnly policy"
  value       = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}