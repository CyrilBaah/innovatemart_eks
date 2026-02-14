# InnovateMart Project Bedrock - EKS Deployment

## Overview
Project Bedrock is InnovateMart's inaugural production-grade microservices deployment on AWS EKS. This repository contains all the Infrastructure as Code, application manifests, and CI/CD pipeline configurations needed to deploy the Retail Store Sample App.

## Project Structure
```
.
├── terraform/              # Terraform infrastructure code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── vpc.tf
│   ├── eks.tf
│   ├── iam.tf
│   ├── s3.tf
│   ├── lambda.tf
│   └── versions.tf
├── k8s-manifests/          # Kubernetes application manifests
│   ├── namespace.yaml
│   └── retail-app/
├── lambda/                 # Lambda function code
│   └── bedrock-asset-processor/
├── .github/workflows/      # CI/CD pipeline
│   └── deploy.yml
├── docs/                   # Project documentation
│   ├── architecture.md
│   └── deployment-guide.md
└── README.md
```

## Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- kubectl
- Helm

### Deployment
1. Clone this repository: `git clone https://github.com/CyrilBaah/innovatemart_eks.git`
2. Configure the pipeline secrets in GitHub
3. Create a Pull Request to trigger `terraform plan`
4. Merge to main to trigger `terraform apply`

## Infrastructure Components

### Core Infrastructure
- **VPC**: `project-bedrock-vpc` with public/private subnets
- **EKS Cluster**: `project-bedrock-cluster` (v1.34+)
- **IAM**: Secure roles and policies for cluster and developer access
- **Remote State**: S3 backend with DynamoDB locking

### Application Layer
- **Retail Store App**: Deployed in `retail-app` namespace
- **Observability**: CloudWatch logging for control plane and containers
- **Security**: RBAC-based developer access

### Serverless Extension
- **S3 Bucket**: `bedrock-assets-[student-id]` for asset uploads
- **Lambda Function**: `bedrock-asset-processor` for auto-processing

## Security & Access
- Developer user: `bedrock-dev-view` with read-only access to AWS and Kubernetes
- All resources tagged with `Project: Bedrock`
- Least privilege IAM policies

## Monitoring & Logging
- EKS Control Plane logging enabled
- Application logs shipped to CloudWatch
- Resource monitoring via CloudWatch metrics

---

**Company**: InnovateMart Inc.  
**Project**: Bedrock  
**Environment**: Production  
**Region**: us-east-1