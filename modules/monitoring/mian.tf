# -------------------------------------------------
# EC2 Instance for monitoring
# -------------------------------------------------
resource "aws_instance" "monitoring" {
  ami                    = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.Monitoring_sg_id]
  user_data              = file("${path.module}/install-Prometheus-and-Grafana-Server.sh")
  iam_instance_profile   = aws_iam_instance_profile.grafana_instance_profile.name

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  tags = {
    Name = "Grafana-Server"
  }
}

# -------------------------------------------------
# IAM Role for Grafana Server (Read-Only Access)
# -------------------------------------------------
resource "aws_iam_role" "grafana_readonly_role" {
  name = "grafana-readonly-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}


# -----------------------------------------------------
# Attach CloudWatch Read-Only Access Policy to IAM Role
# -----------------------------------------------------
resource "aws_iam_role_policy_attachment" "grafana_cloudwatch_readonly_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  role       = aws_iam_role.grafana_readonly_role.name
}

# -----------------------------------------------------
# Attach CloudWatch Logs Read-Only if you want ECS logs
# -----------------------------------------------------
resource "aws_iam_role_policy_attachment" "grafana_cloudwatch_logs_readonly_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"
  role       = aws_iam_role.grafana_readonly_role.name
}

# ------------------------------------------
# IAM Instance Profile for Grafana Server
# ------------------------------------------
resource "aws_iam_instance_profile" "grafana_instance_profile" {
  name = "grafana-instance-profile"
  role = aws_iam_role.grafana_readonly_role.name
}
