output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block for the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  value       = [for subnet in aws_subnet.public : subnet.id] # Loop through public subnets and extract their IDs
}

output "private_subnets_ids" {
  description = "List of Private Subnet IDs"
  value       = [for subnet in aws_subnet.private : subnet.id] # Loop through private subnets and extract their IDs
}