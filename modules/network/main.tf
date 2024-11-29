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
  vpc_id                  = aws_vpc.main.id     # Associate with the VPC
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
  vpc_id                  = aws_vpc.main.id      # Associate with the VPC
  cidr_block              = each.value           # Assign IP range from the map
  map_public_ip_on_launch = false
  availability_zone       = each.key             # Set AZ for the subnet

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
  allocation_id = aws_eip.nat_gateway_eip.id                 # Use the allocated EIP
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
