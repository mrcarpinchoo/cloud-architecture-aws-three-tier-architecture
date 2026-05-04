output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.data.rds_endpoint
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.compute.bastion_public_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}
