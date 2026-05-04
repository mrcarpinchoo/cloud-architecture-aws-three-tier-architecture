variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for private app subnets"
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "CIDR blocks for private DB subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones to deploy into"
  type        = list(string)
}
