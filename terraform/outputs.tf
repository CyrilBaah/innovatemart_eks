output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "assets_bucket_name" {
  description = "Name of the assets S3 bucket"
  value       = aws_s3_bucket.assets_bucket.id
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS node group"
  value       = module.eks.node_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if enabled"
  value       = module.eks.oidc_provider_arn
}

output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks.eks_managed_node_groups
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.asset_processor.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.asset_processor.arn
}

output "developer_access_key_id" {
  description = "Access key ID for developer user"
  value       = aws_iam_access_key.developer_key.id
  sensitive   = true
}

output "developer_secret_access_key" {
  description = "Secret access key for developer user"
  value       = aws_iam_access_key.developer_key.secret
  sensitive   = true
}

output "kubectl_config_command" {
  description = "kubectl config command to connect to the cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

# Output for grading verification
output "grading_info" {
  description = "Information needed for automated grading"
  value = {
    cluster_endpoint        = module.eks.cluster_endpoint
    cluster_name            = module.eks.cluster_name
    region                  = var.aws_region
    vpc_id                  = module.vpc.vpc_id
    assets_bucket_name      = aws_s3_bucket.assets_bucket.id
    lambda_function         = aws_lambda_function.asset_processor.function_name
    developer_user          = aws_iam_user.developer.name
    developer_user_original = var.developer_username
    app_namespace           = var.app_namespace
  }
}