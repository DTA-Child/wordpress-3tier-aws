variable "aws_region" {
  description = "AWS region cho deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Tên project - dùng làm prefix cho resources"
  type        = string
  default     = "wordpress-3tier"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Tên người sở hữu project"
  type        = string
  default     = "thuctap-student"
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block cho VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Danh sách AZs để deploy"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks cho public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks cho private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks cho database subnets"
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.200.0/24"]
}

# RDS Configuration
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "wordpress"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "AWS Key Pair name"
  type        = string
}

variable "min_size" {
  description = "Minimum instances trong ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum instances trong ASG"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired instances trong ASG"
  type        = number
  default     = 2
}

# Domain Configuration (Optional)
variable "domain_name" {
  description = "Domain name cho SSL certificate"
  type        = string
  default     = ""
}

# Monitoring Configuration
variable "alert_email" {
  description = "Email address để nhận alerts"
  type        = string
  default     = ""
}