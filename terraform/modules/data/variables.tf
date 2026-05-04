variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "db_subnet_ids" {
  description = "IDs of the DB subnets"
  type        = list(string)
}

variable "db_sg_id" {
  description = "ID of the DB tier security group"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "countries"
}
