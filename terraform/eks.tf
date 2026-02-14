# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  # Cluster endpoint access
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # VPC and subnet configuration
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    main = {
      name           = "${var.cluster_name}-main"
      instance_types = var.instance_types
      capacity_type  = var.capacity_type

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      # Use custom launch template
      use_custom_launch_template = false

      # Disk size for nodes
      disk_size = 20

      # AMI type
      ami_type = "AL2_x86_64"

      # Remote access (SSH)
      remote_access = {
        ec2_ssh_key = null
        source_security_group_ids = []
      }

      # Update config
      update_config = {
        max_unavailable_percentage = 25
      }

      # Labels
      labels = {
        Environment = "production"
        Application = "retail-store"
      }

      # Taints - None for general workloads
      taints = []

      tags = {
        ExtraTag = "EKS-managed-node-group"
        Project  = "Bedrock"
      }
    }
  }

  # Cluster access entry
  # We'll configure the developer access separately
  enable_cluster_creator_admin_permissions = true

  # CloudWatch logging
  cluster_enabled_log_types = var.enable_control_plane_logging ? var.control_plane_log_types : []

  # EKS Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    # EBS CSI Driver for persistent volumes
    aws-ebs-csi-driver = {
      most_recent = true
    }
    # CloudWatch Observability addon
    amazon-cloudwatch-observability = {
      most_recent = true
    }
  }

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
    # Allow access from ALB (for bonus section)
    ingress_alb_tcp = {
      description = "ALB to cluster"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      type        = "ingress"
      cidr_blocks = [var.vpc_cidr]
    }
    ingress_alb_https = {
      description = "ALB to cluster HTTPS"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  # Extend node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    
    # Allow access to EFS (if needed for persistent storage)
    ingress_efs_tcp = {
      description = "EFS mount target"
      protocol    = "tcp"
      from_port   = 2049
      to_port     = 2049
      type        = "ingress"
      cidr_blocks = [var.vpc_cidr]
    }

    # Allow all egress
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Project = "Bedrock"
  }
}