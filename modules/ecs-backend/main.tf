########################################### BACKEND ###########################################

# ECS Cluster definition
resource "aws_ecs_cluster" "backend_cluster" {
  name = "backend-cluster"

  # Enabling container insights for the ECS cluster (set to 'disabled' in this case)
  setting {
    name  = "containerInsights" # The setting name for enabling container insights
    value = "disabled"          # The value to disable container insights
  }
}

# ECS Task Definition for backend service
resource "aws_ecs_task_definition" "backend_task" {
  family                   = var.business_logic_name
  network_mode             = "awsvpc" # Fargate requires 'awsvpc' mode for networking (VPC networking)
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_execution_role_arn # IAM role for ECS task execution
  task_role_arn            = var.ecs_task_role_arn      # IAM role for the ECS task itself

  # Define CPU and memory at the task level (required for Fargate)
  cpu    = "256"  # CPU for the entire task
  memory = "1024" # Memory for the entire task

  container_definitions = <<TASK_DEFINITION
  [
    {
      "name": "${var.business_logic_name}",
      "image": "${var.image_uri}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "MONGO_URI",
          "value": "mongodb://Moamen:moamen146@${var.documentdb_cluster_endpoint}:27017/?tls=true&tlsCAFile=global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
        },
        {
          "name": "PORT",
          "value": "3000"
        }
      ]
    }
  ]
  TASK_DEFINITION
}


# ECS Service definition
resource "aws_ecs_service" "backend_service" {
  name            = "backend_service"
  cluster         = aws_ecs_cluster.backend_cluster.id
  desired_count   = 2         # Number of tasks to run
  launch_type     = "FARGATE" # ECS launch type is Fargate
  task_definition = aws_ecs_task_definition.backend_task.arn

  network_configuration {
    subnets          = var.private_subnets_ids      # Subnets for the ECS tasks
    security_groups  = [var.business_logic_sg_id]   # Security groups for the ECS tasks
    assign_public_ip = false                        # Assign public IP to the tasks
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.business_logic_target_group.arn
    container_name   = var.business_logic_name
    container_port   = 3000
  }
  depends_on = [aws_lb_target_group.business_logic_target_group]
}

########################################### Application Load Balancer (ALB) ###########################################

# Create an Application Load Balancer (ALB) for the Web App
resource "aws_lb" "business_logic_alb" {
  name               = "business-logic-alb"           # Name of the ALB
  internal           = false                          # Set to false for internet-facing ALB
  load_balancer_type = "application"                  # Type of load balancer (Application Load Balancer)
  subnets            = var.public_subnet_ids          # Use the public subnet IDs from variables
  security_groups    = [var.business_logic_alb_sg_id] # Use the security group ID from variables

  tags = {
    Name = "Internal App Load Balancer" # Tag for identifying the ALB
  }
}

########################################### ALB Listener ###########################################

# Add a Listener to the ALB to forward HTTP traffic to the Target Group
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.business_logic_alb.arn # Associate with the ALB's ARN
  port              = 3000                          # Set the listener port to 3000
  protocol          = "HTTP"                        # Protocol used by the listener

  default_action {
    type             = "forward"                                           # Forward traffic
    target_group_arn = aws_lb_target_group.business_logic_target_group.arn # Forward traffic to the target group
  }
}

########################################### ALB Target Group ###########################################

# Create a Target Group for the ALB to route traffic, with target_type set to 'ip' for Fargate
resource "aws_lb_target_group" "business_logic_target_group" {
  name        = "business-logic-target-group" # Name of the target group
  port        = 3000                          # Port for the target group
  protocol    = "HTTP"                        # Protocol used for routing traffic
  vpc_id      = var.vpc_id                    # VPC ID for the target group
  target_type = "ip"                          # Set target type to 'ip' for Fargate compatibility

  # Health check configuration for the target group
  health_check {
    interval            = 30               # Time between health checks (in seconds)
    path                = "/api/v1/people" # Path used to check the health of the targets
    protocol            = "HTTP"           # Protocol for the health check
    timeout             = 5                # Timeout for health checks (in seconds)
    healthy_threshold   = 2                # Number of successful health checks required to consider the target healthy
    unhealthy_threshold = 2                # Number of failed health checks required to consider the target unhealthy
  }

  tags = {
    Name = "business logic Target Group" # Tag for identifying the target group
  }
}


# resource "aws_cloudwatch_log_group" "backend_log_group" {
#   name = "/ecs/backend"
#   retention_in_days = 7
# }

# resource "aws_cloudwatch_metric_alarm" "backend_cpu_alarm" {
#   alarm_name          = "backend-cpu-high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 1
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/ECS"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 75
#   alarm_description   = "Alarm if backend ECS CPU utilization exceeds 75%"


#   dimensions = {
#     ClusterName = aws_ecs_cluster.backend_cluster.name
#     ServiceName = aws_ecs_service.backend_service.name
#   }

#   actions_enabled = true
#   alarm_actions   = []  # Add SNS Topic for notifications if needed
# }
