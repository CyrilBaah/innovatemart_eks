# AWS Configuration
aws_region = "us-east-1"

# Student Information
student_id = "ALT-SOE-025-0223"

# EKS Cluster Configuration
cluster_name       = "project-bedrock-cluster"
kubernetes_version = "1.31"

# VPC Configuration (Optimized for cost)
vpc_name        = "project-bedrock-vpc"
vpc_cidr        = "10.0.0.0/16"
azs             = ["us-east-1a", "us-east-1b"]  # Reduced from 3 to 2 AZs
private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]  # Reduced from 3 to 2 subnets
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]  # Reduced from 3 to 2 subnets

# EKS Node Group Configuration (Optimized for cost)
instance_types = ["t3.small"]  # Using t3.small instead of t3.medium (50% cost savings)
capacity_type  = "SPOT"        # Using SPOT instances for 70% cost savings
min_size       = 1
max_size       = 10
desired_size   = 1             # Starting with 1 node instead of 2

# IAM Configuration
developer_username = "bedrock-dev-view"

# Lambda Configuration
lambda_function_name = "bedrock-asset-processor"

# Kubernetes Configuration
app_namespace = "retail-app"

# Observability Configuration
enable_control_plane_logging = true
control_plane_log_types = [
  "api",
  "audit",
  "authenticator",
  "controllerManager",
  "scheduler"
]
