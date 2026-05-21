variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Target AWS Region deployment zone"
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Deployment environment namespace tag"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Base CIDR block IP range allocation for the VPC"
}

variable "db_password" {
  type        = string
  default     = "SuperSecurePassword123!"
  sensitive   = true
  description = "Master password credentials for the RDS database instance"
}