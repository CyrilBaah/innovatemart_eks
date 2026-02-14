# Main Terraform configuration file
# This file serves as the entry point and orchestrates all infrastructure components

# Local values for common configurations
locals {
  common_tags = {
    Project     = "Bedrock"
    Environment = "production"
    ManagedBy   = "Terraform"
    Owner       = "InnovateMart-DevOps"
  }

  cluster_name = var.cluster_name
  region      = var.aws_region
}

# Additional resources that might be needed

# Security Group for RDS (for bonus section)
resource "aws_security_group" "rds" {
  name_prefix = "${var.cluster_name}-rds-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "MySQL/Aurora"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  ingress {
    description     = "PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-rds-sg"
  })
}

# CloudWatch Log Group for EKS cluster 
# NOTE: EKS automatically creates log groups when cluster_enabled_log_types is set
# Commenting out to avoid "already exists" error
# resource "aws_cloudwatch_log_group" "eks_cluster" {
#   name              = "/aws/eks/${var.cluster_name}/cluster"
#   retention_in_days = 7
#   tags = local.common_tags
# }