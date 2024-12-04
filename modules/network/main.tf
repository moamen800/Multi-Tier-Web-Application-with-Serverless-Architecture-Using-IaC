####################################### VPC #######################################
# Create the VPC with a defined CIDR block (IP range)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr # Set the IP range for the VPC
  enable_dns_support   = true         # Enable DNS support in the VPC
  enable_dns_hostnames = true         # Enable DNS hostnames in the VPC for resolving addresses
  tags = {
    Name      = var.vpc_name # Name tag for VPC
    Terraform = "true"       # Indicate resource managed by Terraform
  }
}

####################################### Public Subnets ########################################
# Create public subnets across availability zones
resource "aws_subnet" "public" {
  for_each                = var.public_subnets # Create one subnet per AZ
  vpc_id                  = aws_vpc.main.id    # Associate with the VPC
  cidr_block              = each.value         # Assign IP range from the map
  map_public_ip_on_launch = true               # Assign public IP to instances
  availability_zone       = each.key           # Set AZ for each subnet

  tags = {
    Name      = "public_subnet_${each.key}" # Name tag with AZ
    Terraform = "true"
  }
}

# Create a public route table to route traffic through the Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id # Reference the VPC for the route table

  tags = {
    Name      = "public_route_table"
    Terraform = "true"
  }
}

# Add a default route to the Internet Gateway for the public route table
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0" # Route all traffic to the IGW
  gateway_id             = aws_internet_gateway.main.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_assoc" {
  for_each       = aws_subnet.public # Iterate over public subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

####################################### Private Subnets #######################################
# Create private subnets across availability zones
resource "aws_subnet" "private" {
  for_each                = var.private_subnets # Create one subnet per AZ
  vpc_id                  = aws_vpc.main.id     # Associate with the VPC
  cidr_block              = each.value          # Assign IP range from the map
  map_public_ip_on_launch = false               # Do not assign public IP to instances
  availability_zone       = each.key            # Set AZ for the subnet

  tags = {
    Name      = "private_subnet_${each.key}" # Name tag with AZ
    Terraform = "true"
  }
}

# Create a private route table for internal traffic and NAT Gateway access
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id # Reference the VPC for the route table

  tags = {
    Name      = "private_route_table"
    Terraform = "true"
  }
}

# Route outbound traffic from private subnets to the NAT Gateway
resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0" # Route all outbound traffic to the NAT Gateway
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_assoc" {
  for_each       = aws_subnet.private # Iterate over private subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}

####################################### NAT Gateway #######################################
# Allocate an Elastic IP (EIP) for the NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc" # Allocate EIP within the VPC

  tags = {
    Name = "nat_gateway_eip"
  }
}

# Create a NAT Gateway to enable internet access for private subnets
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway_eip.id         # Use the allocated EIP
  subnet_id     = aws_subnet.public["us-east-1a"].id # Attach to a public subnet (ensure correct AZ)

  tags = {
    Name = "nat_gateway"
  }
}

####################################### Internet Gateway #######################################
# Create an Internet Gateway to provide public subnets with internet access
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # Attach the IGW to the VPC

  tags = {
    Name = "internet_gateway"
  }
}

####################################### NACL #######################################
# Create a Network ACL for the private subnets
resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.main.id # Associate with the VPC

  tags = {
    Name      = "private_network_acl"
    Terraform = "true"
  }
}

# Allow inbound traffic on the private subnet NACL
resource "aws_network_acl_rule" "private_nacl_inbound" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

# Allow outbound traffic from the private subnet NACL
resource "aws_network_acl_rule" "private_nacl_outbound" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

# Associate the private subnets with the custom NACL
resource "aws_network_acl_association" "private_nacl_assoc" {
  for_each          = aws_subnet.private # Iterate over private subnets
  subnet_id         = each.value.id
  network_acl_id    = aws_network_acl.private_nacl.id
}


# ####################################### CloudWatch #######################################
# # CloudWatch Log Group to store VPC flow logs for the network module
# resource "aws_cloudwatch_log_group" "network_vpc_flow_log_group" {
#   name              = "/aws/vpc/flow-logs"
#   retention_in_days = 90 # Customize retention as needed
# }

# # Create VPC Flow Logs and associate with the CloudWatch Log group and IAM Role for network module
# resource "aws_flow_log" "network_vpc_flow_logs" {
#   log_destination = aws_cloudwatch_log_group.network_vpc_flow_log_group.arn # CloudWatch log group for flow logs
#   traffic_type    = "ALL"                                                   # Types of traffic to log (ALL, ACCEPT, REJECT)
#   vpc_id          = aws_vpc.main.id                                         # VPC ID for which to create flow logs
#   iam_role_arn    = aws_iam_role.network_vpc_flow_log_role.arn              # IAM Role that grants permissions to CloudWatch Logs
# }

# # IAM Role that allows VPC flow logs to assume this role for the network module
# resource "aws_iam_role" "network_vpc_flow_log_role" {
#   name               = "network_vpc_flow_log_role"
#   assume_role_policy = data.aws_iam_policy_document.network_assume_role.json
# }

# # Attach the policy to the IAM role for network module VPC flow logs
# resource "aws_iam_role_policy" "network_vpc_flow_log_policy" {
#   name   = "network_vpc_flow_log_policy"
#   role   = aws_iam_role.network_vpc_flow_log_role.id
#   policy = data.aws_iam_policy_document.network_flow_log_policy.json
# }

# # IAM policy document to allow sts:AssumeRole for VPC Flow Logs in the network module
# data "aws_iam_policy_document" "network_assume_role" {
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["vpc-flow-logs.amazonaws.com"]
#     }
#     actions = ["sts:AssumeRole"]
#   }
# }

# # IAM policy document granting permissions for CloudWatch Logs in the network module
# data "aws_iam_policy_document" "network_flow_log_policy" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams"
#     ]
#     resources = ["*"]
#   }
# }
