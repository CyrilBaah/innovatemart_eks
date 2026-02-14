# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Bedrock"
      Environment = "production"
      ManagedBy   = "Terraform"
      Owner       = "InnovateMart-DevOps"
    }
  }
}

# Helm provider commented out - not currently using Helm resources in Terraform
# If you need to deploy Helm charts via Terraform in the future, uncomment this:
# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#     
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "aws"
#       args = [
#         "eks",
#         "get-token",
#         "--cluster-name",
#         module.eks.cluster_name,
#         "--region",
#         var.aws_region
#       ]
#     }
#   }
# }
