terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket       = "REPLACE_WITH_UNIQUE_TERRAFORM_STATE_BUCKET"
    key          = "flask-aws-ecs-devsecops/terraform.tfstate"
    region       = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "flask-aws-ecs-devsecops"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}
