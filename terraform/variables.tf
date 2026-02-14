variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "bedrock-eks"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "project-bedrock-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "instance_types" {
  description = "EC2 instance types for EKS node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "capacity_type" {
  description = "Capacity type for EKS node group"
  type        = string
  default     = "SPOT"
}

variable "min_size" {
  description = "Minimum number of nodes in EKS node group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of nodes in EKS node group"
  type        = number
  default     = 10
}

variable "desired_size" {
  description = "Desired number of nodes in EKS node group"
  type        = number
  default     = 1
}

variable "student_id" {
  description = "Student ID for unique resource naming"
  type        = string
  default     = "ALT-SOE-025-0223"
}

variable "developer_username" {
  description = "Developer IAM username"
  type        = string
  default     = "bedrock-dev-view"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "bedrock-asset-processor"
}

variable "app_namespace" {
  description = "Kubernetes namespace for the retail app"
  type        = string
  default     = "retail-app"
}

variable "enable_control_plane_logging" {
  description = "Enable EKS control plane logging"
  type        = bool
  default     = true
}

variable "control_plane_log_types" {
  description = "List of control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}