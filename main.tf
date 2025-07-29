# Data sources
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name            = var.project_name
  environment            = var.environment
  vpc_cidr               = var.vpc_cidr
  availability_zones     = var.availability_zones
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  database_subnet_cidrs  = var.database_subnet_cidrs
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
}

# S3 Module
module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  project_name  = var.project_name
  environment   = var.environment
  s3_bucket_arn = module.s3.bucket_arn
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  project_name          = var.project_name
  environment          = var.environment
  database_subnet_ids  = module.vpc.database_subnet_ids
  db_subnet_group_name = module.vpc.db_subnet_group_name
  db_security_group_id = module.security_groups.rds_security_group_id
  db_instance_class    = var.db_instance_class
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
}

# ALB Module
module "alb" {
  source = "./modules/alb"

  project_name           = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
}

# Auto Scaling Group Module
module "asg" {
  source = "./modules/asg"

  project_name            = var.project_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  web_security_group_id  = module.security_groups.web_security_group_id
  target_group_arn       = module.alb.target_group_arn
  instance_type          = var.instance_type
  key_name               = var.key_name
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.desired_capacity
  ami_id                 = data.aws_ami.amazon_linux.id
  instance_profile_name  = module.iam.instance_profile_name
  
  # Database connection info
  db_endpoint    = module.rds.db_endpoint
  db_name        = var.db_name
  db_username    = var.db_username
  db_password    = var.db_password
  s3_bucket_name = module.s3.bucket_name
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  project_name             = var.project_name
  environment             = var.environment
  aws_region              = var.aws_region
  alb_arn_suffix          = module.alb.alb_arn_suffix
  asg_name                = module.asg.asg_name
  db_instance_identifier  = module.rds.db_instance_identifier
  alert_email             = var.alert_email
}