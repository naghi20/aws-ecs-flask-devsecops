variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for AWS resource naming"
  type        = string
  default     = "flask-aws-ecs-devsecops"
}

variable "container_port" {
  description = "Port exposed by the Flask container"
  type        = number
  default     = 8000
}

variable "ecs_desired_count" {
  description = "Number of ECS tasks to maintain"
  type        = number
  default     = 2
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "appadmin"
}

variable "db_name" {
  description = "Initial RDS database name"
  type        = string
  default     = "appdb"
}
