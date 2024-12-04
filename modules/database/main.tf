####################################### MongoDB Database #######################################

# Create Subnet Group for Amazon DocumentDB Cluster
resource "aws_docdb_subnet_group" "documentdb_subnet_group" {
  name       = "documentdb-subnet-group"        # Name for the subnet group
  subnet_ids = var.private_subnets_ids         # Specify actual private subnet IDs within your VPC

  # Add tags to help identify and categorize the resource
  tags = {
    Name = "DocumentDB Subnet Group"
  }
}

# Create Amazon DocumentDB Cluster
resource "aws_docdb_cluster" "documentdb_cluster" {
  cluster_identifier     = var.db_name                                         # Unique identifier for the DocumentDB cluster
  master_username        = var.db_username                                     # Master username for the database
  master_password        = var.db_password                                     # Master password for the database (use a secure password)
  skip_final_snapshot    = true                                                # Skip final snapshot during deletion (usually for dev environments)
  db_subnet_group_name   = aws_docdb_subnet_group.documentdb_subnet_group.name # Attach to the previously defined subnet group
  vpc_security_group_ids = [var.DocumentDB_sg]                                 # Attach the specified security group to the cluster
  storage_encrypted      = true                                                # Enable encryption at rest for the database storage (highly recommended for production)

  # Tags to organize and identify the resource
  tags = {
    Name = "DocumentDB Cluster"
  }
}

# Create an instance in the DocumentDB Cluster
resource "aws_docdb_cluster_instance" "documentdb_instance" {
  cluster_identifier = aws_docdb_cluster.documentdb_cluster.id # Reference the DocumentDB cluster
  instance_class     = "db.t3.medium"                          # Instance type for the database (choose an appropriate size based on workload)
  engine             = "docdb"                                 # Set the engine type to DocumentDB (compatible with MongoDB)

  # Tags to help identify the instance
  tags = {
    Name = "DocumentDB Instance"
  }
}

# ####################################### CloudWatch #######################################

# # Create CloudWatch Metric Alarm for high CPU utilization on DocumentDB Cluster
# resource "aws_cloudwatch_metric_alarm" "documentdb_cpu_alarm" {
#   alarm_name          = "documentdb-cpu-high"                 # Alarm name for easy identification
#   comparison_operator = "GreaterThanThreshold"                # Set condition: "GreaterThanThreshold" to trigger when CPU usage is too high
#   evaluation_periods  = 1                                     # Check the metric every 1 evaluation period
#   metric_name         = "CPUUtilization"                      # Metric name for monitoring CPU utilization
#   namespace           = "AWS/DocDB"                           # Specify the AWS DocDB namespace to monitor metrics specific to DocumentDB
#   period              = 300                                   # The granularity (in seconds) of the metric data (300 seconds = 5 minutes)
#   statistic           = "Average"                             # Use the average CPU utilization for the metric
#   threshold           = 75                                    # Set the threshold for triggering the alarm at 75% CPU utilization
#   alarm_description   = "Alarm if DocumentDB CPU utilization exceeds 75%" # Description for the alarm

#   # Define the dimensions of the metric to monitor the specific DocumentDB cluster
#   dimensions = {
#     DBClusterIdentifier = aws_docdb_cluster.documentdb_cluster.id # Reference the DocumentDB cluster ID
#   }

#   # Enable actions for the alarm (can be linked to SNS for notifications)
#   actions_enabled = true
#   alarm_actions   = []  # Define actions like SNS topics to notify when the alarm state is triggered
# }
