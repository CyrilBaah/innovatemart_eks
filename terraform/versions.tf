terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }

  # Remote state backend configuration
  backend "s3" {
    bucket         = "bedrock-tfstate-alt-soe-025-0223"
    key            = "bedrock/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "bedrock-terraform-state-lock"
    encrypt        = true
  }
}