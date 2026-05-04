# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name        = "project-${var.environment}-subnet-group-mysql"
  description = "DB subnet group for MySQL"
  subnet_ids  = var.db_subnet_ids

  tags = {
    Name = "project-${var.environment}-subnet-group-mysql"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "main" {
  identifier        = "project-${var.environment}-mysql-db01"
  engine            = "mysql"
  engine_version    = "8.4.8"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = var.db_name
  username = "admin"

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  availability_zone      = "us-east-1a"
  multi_az               = false
  publicly_accessible    = false

  backup_retention_period     = 0
  skip_final_snapshot         = true
  deletion_protection         = false
  performance_insights_enabled = false

  tags = {
    Name = "project-${var.environment}-mysql-db01"
  }
}
