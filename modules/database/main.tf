####################################### MongoDB Database #######################################
# Create Subnet Group for Amazon DocumentDB Cluster
resource "aws_docdb_subnet_group" "documentdb_subnet_group" {
  name       = "documentdb-subnet-group"        # Name for the subnet group
  subnet_ids = var.public_subnet_documentDB_ids # Specify actual subnet IDs within your VPC

  tags = {
    Name = "DocumentDB Subnet Group"
  }
}

# Create Amazon DocumentDB Cluster
resource "aws_docdb_cluster" "documentdb_cluster" {
  cluster_identifier     = var.db_name                                         # Unique identifier for the cluster
  master_username        = var.db_username                                     # Master username for the database
  master_password        = var.db_password                                     # Master password for the database (use a secure password)
  skip_final_snapshot    = true                                                # Skip final snapshot during deletion (optional for dev environments)
  db_subnet_group_name   = aws_docdb_subnet_group.documentdb_subnet_group.name # Attach to the subnet group
  vpc_security_group_ids = [var.DocumentDB_sg]                                 # Attach to the security group
  storage_encrypted      = true                                                # Enable storage encryption for security

  tags = {
    Name = "DocumentDB Cluster"
  }
}

# Create an instance in the DocumentDB Cluster
resource "aws_docdb_cluster_instance" "documentdb_instance" {
  cluster_identifier = aws_docdb_cluster.documentdb_cluster.id # Reference the DocumentDB cluster
  instance_class     = "db.t3.medium"                          # Choose instance type for the database
  engine             = "docdb"                                 # Set the engine type to DocumentDB

  tags = {
    Name = "DocumentDB Instance"
  }
}

