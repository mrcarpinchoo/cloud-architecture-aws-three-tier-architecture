variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "IDs of the private app subnets"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "ID of the ALB security group"
  type        = string
}

variable "app_sg_id" {
  description = "ID of the app tier security group"
  type        = string
}

variable "bastion_sg_id" {
  description = "ID of the bastion security group"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket containing app artifacts"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "asg_desired_size" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 4
}

variable "asg_cpu_target" {
  description = "Target CPU utilization percentage for ASG scaling policy"
  type        = number
  default     = 60
}
