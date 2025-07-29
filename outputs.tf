output "website_url" {
  description = "URL để truy cập WordPress site"
  value       = "http://${module.alb.alb_dns_name}"
}

output "alb_dns_name" {
  description = "DNS name của Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "s3_bucket_name" {
  description = "S3 bucket name cho media storage"
  value       = module.s3.bucket_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "nat_gateway_ip" {
  description = "NAT Gateway public IP"
  value       = module.vpc.nat_gateway_ip
}

output "dashboard_url" {
  description = "URL của CloudWatch Dashboard"
  value       = module.monitoring.dashboard_url
}

output "sns_topic_arn" {
  description = "SNS Topic ARN cho alerts"
  value       = module.monitoring.sns_topic_arn
}

output "s3_bucket_domain" {
  description = "S3 bucket domain name"
  value       = module.s3.bucket_domain_name
}

output "cost_estimation" {
  description = "Ước tính chi phí hàng tháng (USD)"
  value = {
    ec2_instances = "~$17 (2 x t3.micro)"
    rds_instance  = "~$12 (db.t3.micro)"
    alb           = "~$16"
    nat_gateway   = "~$32"
    s3_storage    = "~$2 (first 50GB)"
    data_transfer = "~$5"
    total         = "~$84/month"
  }
}

output "target_group_arn" {
  description = "ALB Target Group ARN"
  value       = module.alb.target_group_arn
}