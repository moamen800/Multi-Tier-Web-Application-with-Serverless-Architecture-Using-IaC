# This file contains the variables used in the Terraform configuration.
aws_region  = "eu-west-1"
aws_profile = "default"
key_name    = "keypair_Ireland"
image_id    = "ami-0df368112825f8d8f"

# The following variables are specific to the network module
vpc_name = "multi-tier-vpc"
vpc_cidr = "10.0.0.0/16"

public_subnets = {
  "eu-west-1a" = "10.0.1.0/24"
  "eu-west-1b" = "10.0.2.0/24"
}

private_subnets = {
  "eu-west-1a" = "10.0.100.0/24"
  "eu-west-1b" = "10.0.200.0/24"
}

# The following variables are specific to the database module
db_name     = "mydatabase14121414"
db_username = "Moamen"
db_password = "moamen146"

# The following variables are specific to the ECS Frontend module
family_name_frontend = "Frontend-Container"
image_uri_frontend   = "307946672811.dkr.ecr.eu-west-1.amazonaws.com/frontend-mern:latest"

# The following variables are specific to the ECS Backend module
family_name_backend = "Backend-container"
image_uri_backend   = "307946672811.dkr.ecr.eu-west-1.amazonaws.com/backend-mern:latest"