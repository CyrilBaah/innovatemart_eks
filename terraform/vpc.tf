# Data sources
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  # Use available AZs up to the number specified in variables
  azs = slice(data.aws_availability_zones.available.names, 0, min(length(data.aws_availability_zones.available.names), length(var.azs)))
}

# VPC Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  # Enable NAT Gateway for private subnets
  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true # Use single NAT gateway for cost optimization
  one_nat_gateway_per_az = false

  # Enable DNS
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags for EKS
  public_subnet_tags = {
    Name                                        = "${var.vpc_name}-public"
    "kubernetes.io/role/elb"                   = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    Name                                        = "${var.vpc_name}-private"
    "kubernetes.io/role/internal-elb"          = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  vpc_tags = {
    Name = var.vpc_name
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  # Internet Gateway tags
  igw_tags = {
    Name = "${var.vpc_name}-igw"
  }

  # NAT Gateway tags
  nat_gateway_tags = {
    Name = "${var.vpc_name}-nat"
  }

  # NAT EIP tags
  nat_eip_tags = {
    Name = "${var.vpc_name}-nat-eip"
  }

  tags = {
    Project = "Bedrock"
  }
}