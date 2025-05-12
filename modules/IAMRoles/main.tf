########################################### IAM Roles ###########################################

# Resource definition for IAM role used by ECS tasks (execution role)
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role" # Name of the IAM role used by ECS tasks for execution

  # Trust policy allowing ECS tasks to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com" # Allow ECS tasks to assume this role
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

# Resource definition for IAM policy that allows ECS tasks to pull images from ECR
resource "aws_iam_policy" "ecs_execution_policy" {
  name        = "ecs_execution_policy"
  description = "Policy to allow ECS tasks to pull images from ECR, write to logs, and send metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeRepositories",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "elasticloadbalancing:DescribeLoadBalancers"
        ]
        Resource = "*"
      }
    ]
  })
}


# Attach the custom ECR policy to the ECS execution role
resource "aws_iam_role_policy_attachment" "ecs_execution_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
}

# Attach the AmazonEC2ContainerRegistryReadOnly policy to the ECS execution role
resource "aws_iam_role_policy_attachment" "ecs_execution_role_readonly_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" # Attach the ECR read-only policy
}

# Resource definition for IAM role used by ECS tasks (task role)
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role" # Name of the IAM role for the ECS task itself

  # Trust policy allowing ECS tasks to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com" # Allow ECS tasks to assume this role
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

