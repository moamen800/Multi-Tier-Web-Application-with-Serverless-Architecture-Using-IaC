####################################### VPC #######################################
# Create the VPC with a defined CIDR block (IP range)
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr # Set the IP range for the VPC
  enable_dns_support   = true         # Enable DNS support in the VPC
  enable_dns_hostnames = true         # Enable DNS hostnames in the VPC for resolving addresses
  tags = {
    Name      = var.vpc_name # Name tag for VPC
    Terraform = "true"       # Indicate resource managed by Terraform
  }
}

####################################### Public Subnets WEB #######################################
# Create public subnets across availability zones
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets # Create one subnet per AZ
  vpc_id                  = aws_vpc.vpc.id     # Associate with the VPC
  cidr_block              = each.value         # Assign IP range from the map
  map_public_ip_on_launch = true               # Assign public IP to instances
  availability_zone       = each.key           # Set AZ for each subnet

  tags = {
    Name      = "${each.key}_public_subnet" # Name tag with AZ
    Terraform = "true"
  }
}

# Create a public route table to route traffic through the Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id # Reference the VPC for the route table

  tags = {
    Name      = "public_route_table"
    Terraform = "true"
  }
}

# Add a default route to the Internet Gateway for the public route table
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0" # Route all traffic to the IGW
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_assoc" {
  for_each       = aws_subnet.public_subnets # Iterate over public subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}


####################################### Public Subnets for documentDB #######################################
# Create public subnets across availability zones
resource "aws_subnet" "public_subnets_documentDB" {
  for_each                = var.public_subnets_documentDB # Create one subnet per AZ
  vpc_id                  = aws_vpc.vpc.id                # Associate with the VPC
  cidr_block              = each.value                    # Assign IP range from the map
  map_public_ip_on_launch = true                          # Assign public IP to instances
  availability_zone       = each.key                      # Set AZ for each subnet

  tags = {
    Name      = "${each.key}_public_subnet_documentDB" # Name tag with AZ
    Terraform = "true"
  }
}

# Create a public route table to route traffic through the Internet Gateway
resource "aws_route_table" "public_rt_documentDB" {
  vpc_id = aws_vpc.vpc.id # Reference the VPC for the route table

  tags = {
    Name      = "public_route_table"
    Terraform = "true"
  }
}

# Add a default route to the Internet Gateway for the public route table
resource "aws_route" "public_internet_access_documentDB" {
  route_table_id         = aws_route_table.public_rt_documentDB.id
  destination_cidr_block = "0.0.0.0/0" # Route all traffic to the IGW
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_assoc_documentDB" {
  for_each       = aws_subnet.public_subnets_documentDB # Iterate over public subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt_documentDB.id
}


####################################### Internet Gateway #######################################
# Create an Internet Gateway to provide public subnets with internet access
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id # Attach the IGW to the VPC

  tags = {
    Name = "igw"
  }
}
