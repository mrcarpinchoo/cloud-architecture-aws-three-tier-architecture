# Bastion Security Group
resource "aws_security_group" "bastion" {
  name        = "project-${var.environment}-sg-bastion"
  description = "Bastion host security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from admin device"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-${var.environment}-sg-bastion"
  }
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "project-${var.environment}-sg-alb"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "Forward to app tier"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = {
    Name = "project-${var.environment}-sg-alb"
  }
}

# App Tier Security Group
resource "aws_security_group" "app" {
  name        = "project-${var.environment}-sg-app"
  description = "App tier security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "SSH from bastion only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    description     = "MySQL to DB tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.db.id]
  }

  egress {
    description = "HTTPS outbound (AWS APIs, S3, dnf updates)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-${var.environment}-sg-app"
  }
}

# DB Tier Security Group
resource "aws_security_group" "db" {
  name        = "project-${var.environment}-sg-db"
  description = "DB tier security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "project-${var.environment}-sg-db"
  }
}

resource "aws_security_group_rule" "db_ingress_app" {
  description              = "MySQL from app tier only"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "db_ingress_bastion" {
  description              = "MySQL from bastion"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.bastion.id
}
