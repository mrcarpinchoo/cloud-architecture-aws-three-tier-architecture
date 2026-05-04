output "alb_sg_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "app_sg_id" {
  description = "ID of the app tier security group"
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "ID of the DB tier security group"
  value       = aws_security_group.db.id
}

output "bastion_sg_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.bastion.id
}
