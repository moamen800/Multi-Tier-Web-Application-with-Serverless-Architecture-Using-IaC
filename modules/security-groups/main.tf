####################################### ALB Security Group (presentation_alb_sg) #######################################
resource "aws_security_group" "presentation_alb_sg" {
  name   = "presentation_alb_sg"
  vpc_id = var.vpc_id

  # HTTP Ingress (Port 80) – Allow incoming HTTP traffic to the ALB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule – Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 allows all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "presentation-alb-sg"
  }
}

####################################### Web Security Group (presentation_sg) #######################################
resource "aws_security_group" "presentation_sg" {
  name   = "presentation_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.presentation_alb_sg.id]
  }

  # Allow SSH (Port 22) – Use with caution, allows SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule – Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 allows all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "presentation-sg"
  }
}

####################################### ALB Security Group (business_logic_alb_sg) #######################################
resource "aws_security_group" "business_logic_alb_sg" {
  name   = "business-logic-alb_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = [aws_security_group.presentation_sg.id]
  }

  # Outbound rule – Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 allows all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "business_logic-alb-sg"
  }
}

####################################### business_logic Security Group (business_logic_sg) #######################################
resource "aws_security_group" "business_logic_sg" {
  name   = "business-logic_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.business_logic_alb_sg.id]

  }

  # Allow SSH (Port 22) – Use with caution, allows SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule – Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 allows all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "business-logic-sg"
  }
}

###################################### database Security Group (DocumentDB_sg) #######################################
resource "aws_security_group" "DocumentDB_sg" {
  name        = "DocumentDB_sg"
  description = "Allow access to MONGO DB"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 27017
    to_port   = 27017
    protocol  = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.business_logic_sg.id]
  }

  # Outbound rule – Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 allows all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DocumentDB_sg"
  }
}
