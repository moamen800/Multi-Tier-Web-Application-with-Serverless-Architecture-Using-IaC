####################################### VPC Outputs #######################################
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "vpc_cidr" {
  description = "CIDR block for the VPC"
  value       = aws_vpc.vpc.cidr_block
}

output "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  value       = [for subnet in aws_subnet.public_subnets : subnet.id] # Loop through public subnets and extract their IDs
}

output "public_subnet_documentDB_ids" {
  description = "List of Public Subnet IDs"
  value       = [for subnet in aws_subnet.public_subnets_documentDB : subnet.id] # Loop through public subnets and extract their IDs
}