########################################### ECS Frontend ###########################################

# ECS Cluster - Defines the ECS cluster where the tasks will run
resource "aws_ecs_cluster" "frontend_cluster" {
  name = "frontend_cluster" # Name of the ECS cluster

  setting {
    name  = "containerInsights" # Enable container insights for monitoring and logging
    value = "enabled"           # Set to "enabled" to activate container insights
  }
}

# ECS Task Definition - Defines the task with Fargate compatibility and resource allocation
resource "aws_ecs_task_definition" "frontend_task" {
  family                   = var.family_name            # Task family name (presentation name)
  network_mode             = "awsvpc"                   # Network mode for the task (use awsvpc for Fargate)
  requires_compatibilities = ["FARGATE"]                # Ensures task uses Fargate launch type
  execution_role_arn       = var.ecs_execution_role_arn # IAM role for ECS task execution (permissions for AWS services)
  task_role_arn            = var.ecs_task_role_arn      # IAM role for ECS tasks (permissions for containers)

  cpu    = "256"  # CPU units (0.25 vCPU)
  memory = "1024" # Memory allocation (1024 MiB)
  
  # Container definition (this is where you define the container settings)
  container_definitions = <<TASK_DEFINITION
  [
    {
      "name": "Frontend-Container",  
      "image": "${var.image_uri}",  
      "essential": true,  
      "portMappings": [
        {
          "containerPort": 80, 
          "hostPort": 80,  
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "ALBDNS",
          "value": "${var.business_logic_alb_dns_name}"
        }
      ]      
    }
  ]
  TASK_DEFINITION
}

########################################### ECS Backend ###########################################
# ECS Service - Defines the ECS service to manage the task definition (with auto-scaling, desired count, etc.)
resource "aws_ecs_service" "frontend_service" {
  name            = "frontend_service"                        # Name of the ECS service
  cluster         = aws_ecs_cluster.frontend_cluster.id       # Reference to the ECS cluster
  task_definition = aws_ecs_task_definition.frontend_task.arn # Reference to the task definition
  desired_count   = 2                                         # Number of tasks to run (1 task here)
  launch_type     = "FARGATE"                                 # Launch type (Fargate)

  network_configuration {
    subnets          = var.public_subnet_ids    # Subnets for the service (public subnets for internet access)
    security_groups  = [var.presentation_sg_id] # Security group IDs (to control inbound/outbound traffic)
    assign_public_ip = true                     # Assign public IP to ECS tasks so they can be accessed over the internet
  }

  # Attach the service to an Application Load Balancer (ALB)
  load_balancer {
    target_group_arn = aws_lb_target_group.presentation_target_group.arn # The target group associated with the ALB
    container_name   = "Frontend-Container"                              # The container in the task to route traffic to
    container_port   = 80                                                # Port on the container to route traffic to (must match the port in container definition)
  }
  depends_on = [aws_lb_target_group.presentation_target_group]
}


# Application Load Balancer (ALB) - Defines an internet-facing load balancer for routing traffic to ECS service
resource "aws_lb" "presentation_alb" {
  name               = "presentation-alb"           # Name of the load balancer
  internal           = false                        # Indicates that this is an internet-facing ALB
  load_balancer_type = "application"                # Specifies that it's an application load balancer
  subnets            = var.public_subnet_ids        # Subnets for the load balancer (public subnets for internet access)
  security_groups    = [var.presentation_alb_sg_id] # Security group for the load balancer

  tags = {
    Name = "Internet-Facing App Load Balancer" # Tag for identification
  }
}

# ALB Listener - Defines the listener for the ALB that will forward traffic to the target group
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.presentation_alb.arn # Reference to the load balancer
  port              = 80                          # HTTP port (80) for inbound traffic
  protocol          = "HTTP"                      # Protocol for the listener

  # Default action to forward traffic to the target group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.presentation_target_group.arn # The target group to forward traffic to
  }
}

# ALB Target Group - Defines the target group for the ALB, which routes traffic to the ECS service
resource "aws_lb_target_group" "presentation_target_group" {
  name        = "presentation-target-group" # Name of the target group
  port        = 80                          # Port for routing traffic (must match the container's exposed port)
  protocol    = "HTTP"                      # HTTP protocol
  vpc_id      = var.vpc_id                  # VPC ID where the target group is located
  target_type = "ip"                        # Use IP addresses as targets (for Fargate tasks, which don't have a fixed IP)

  # Health check configuration for the target group
  health_check {
    interval            = 30     # Interval between health checks (seconds)
    path                = "/"    # Path for health check (root URL)
    protocol            = "HTTP" # Protocol for health check
    timeout             = 5      # Timeout for health check (seconds)
    healthy_threshold   = 2      # Number of consecutive successful health checks before considered healthy
    unhealthy_threshold = 2      # Number of consecutive failed health checks before considered unhealthy
  }

  tags = {
    Name = "presentation Target Group" # Tag for identification
  }
}

# resource "aws_cloudwatch_log_group" "frontend_log_group" {
#   name = "/ecs/frontend"
#   retention_in_days = 7  # Customize retention
# }

# resource "aws_cloudwatch_metric_alarm" "frontend_cpu_alarm" {
#   alarm_name          = "frontend-cpu-high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 1
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/ECS"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 75
#   alarm_description   = "Alarm if frontend ECS CPU utilization exceeds 75%"

#   dimensions = {
#     ClusterName = aws_ecs_cluster.frontend_cluster.name
#     ServiceName = aws_ecs_service.frontend_service.name
#   }

#   actions_enabled = true
#   alarm_actions   = []  # Add SNS Topic for notifications if needed
# }
