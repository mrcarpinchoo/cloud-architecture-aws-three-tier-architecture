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

  tags = {
    Name = "project-${var.environment}-sg-alb"
  }
}

# App Tier Security Group
resource "aws_security_group" "app" {
  name        = "project-${var.environment}-sg-app"
  description = "App tier security group"
  vpc_id      = var.vpc_id

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

# ALB rules
resource "aws_security_group_rule" "alb_ingress_http" {
  description       = "HTTP from internet"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress_app" {
  description              = "Forward to app tier"
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.app.id
}

# App rules
resource "aws_security_group_rule" "app_ingress_alb" {
  description              = "HTTP from ALB only"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "app_ingress_bastion" {
  description              = "SSH from bastion only"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "app_egress_db" {
  description              = "MySQL to DB tier"
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.db.id
}

resource "aws_security_group_rule" "app_egress_https" {
  description       = "HTTPS outbound (AWS APIs, S3, dnf updates)"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# DB rules
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
