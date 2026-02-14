# AWS Configuration
aws_region = "us-east-1"

# Student Information
student_id = "ALT-SOE-025-0223"

# EKS Cluster Configuration
cluster_name       = "project-bedrock-cluster" # Required naming convention
kubernetes_version = "1.31"

# VPC Configuration (Optimized for cost)
vpc_name        = "project-bedrock-vpc" # Required naming convention
vpc_cidr        = "10.0.0.0/16"
azs             = ["us-east-1a", "us-east-1b"]       # 2 AZs for HA with cost optimization
private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]     # 2 private subnets
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"] # 2 public subnets

# EKS Node Group Configuration (Cost-optimized for development)
instance_types = ["t3.medium", "t3.small"] # Multiple instance types for better SPOT availability
capacity_type  = "SPOT"                    # SPOT instances for 60-90% cost savings
min_size       = 1                         # Minimum for HA
max_size       = 5                         # Reduced max for cost control
desired_size   = 2                         # 2 nodes for proper HA

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
