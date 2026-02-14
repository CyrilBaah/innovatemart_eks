# Project Bedrock - Deployment Guide

## Prerequisites

Before deploying Project Bedrock, ensure you have the following:

### Required Tools
- **AWS CLI** (version 2.0+): [Installation guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- **Terraform** (version 1.0+): [Installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **kubectl**: [Installation guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- **Helm** (version 3.0+): [Installation guide](https://helm.sh/docs/intro/install/)
- **Git**: For repository management

### AWS Account Setup
1. **AWS Account**: Active AWS account with billing enabled
2. **IAM Permissions**: Administrative access or the following permissions:
   - EC2 Full Access
   - EKS Full Access
   - IAM Full Access
   - VPC Full Access
   - CloudWatch Full Access
   - S3 Full Access
   - Lambda Full Access

### GitHub Repository Setup
1. **Fork or Clone**: This repository
2. **Repository Secrets**: Configure the following secrets in your GitHub repository:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key

## Quick Start

### Step 1: Clone the Repository
```bash
git clone https://github.com/CyrilBaah/innovatemart_eks.git
cd innovatemart_eks
```

### Step 2: Configure AWS CLI
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region (us-east-1)
```

### Step 3: Set Up Terraform Backend
Before running Terraform, you need to create the S3 bucket and DynamoDB table for remote state:

```bash
# Create S3 bucket for Terraform state
aws s3 mb s3://bedrock-terraform-state-bucket --region us-east-1

# Enable versioning on the bucket
aws s3api put-bucket-versioning \
  --bucket bedrock-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name bedrock-terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

### Step 4: Deploy Infrastructure

#### Option A: Using CI/CD Pipeline (Recommended)
1. Push your changes to a feature branch
2. Create a Pull Request to trigger `terraform plan`
3. Review the plan in the PR comments
4. Merge to main branch to trigger `terraform apply`

#### Option B: Local Deployment
```bash
cd terraform

# Initialize Terraform
terraform init

# Create a plan
terraform plan -out=tfplan

# Review the plan and apply
terraform apply tfplan
```

### Step 5: Configure kubectl
```bash
# Update kubeconfig to connect to the EKS cluster
aws eks update-kubeconfig --region us-east-1 --name project-bedrock-cluster

# Verify connection
kubectl cluster-info
```

### Step 6: Deploy Application
```bash
# Apply namespace
kubectl apply -f k8s-manifests/namespace.yaml

# Deploy the retail store application
cd k8s-manifests/retail-app
chmod +x deploy.sh
./deploy.sh
```

### Step 7: Verify Deployment
```bash
# Check all pods are running
kubectl get pods -n retail-app

# Check services
kubectl get services -n retail-app

# Check logs
kubectl logs -n retail-app -l app=ui
```

## Accessing the Application

### Local Access
```bash
# Port forward to access the UI
kubectl port-forward -n retail-app svc/ui 8080:80

# Open in browser: http://localhost:8080
```

### LoadBalancer Access (Bonus Feature)
If you've implemented the ALB ingress controller:
```bash
# Get the LoadBalancer URL
kubectl get ingress -n retail-app
```

## Testing the Serverless Extension

### Upload a Test File to S3
```bash
# Upload a test image file
aws s3 cp test-image.jpg s3://bedrock-assets-ALT-SOE-025-0223/

# Check Lambda function logs
aws logs tail /aws/lambda/bedrock-asset-processor --follow
```

## Developer Access Testing

### Test IAM User Permissions
```bash
# Configure AWS CLI with developer credentials
aws configure --profile developer
# Enter the bedrock-dev-view access key and secret

# Test read-only access
aws ec2 describe-instances --profile developer  # Should work
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0 --profile developer  # Should fail

# Test S3 bucket access
aws s3 cp test-file.txt s3://bedrock-assets-ALT-SOE-025-0223/ --profile developer  # Should work
```

### Test Kubernetes RBAC
```bash
# Update kubeconfig with developer user
aws eks update-kubeconfig --region us-east-1 --name project-bedrock-cluster --profile developer

# Test read permissions
kubectl get pods -n retail-app  # Should work

# Test write permissions (should fail)
kubectl delete pod [pod-name] -n retail-app  # Should fail with RBAC error
```

## Monitoring and Observability

### View CloudWatch Logs
```bash
# EKS Control Plane logs
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/project-bedrock-cluster"

# Application logs
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/project-bedrock-cluster/application"

# Lambda function logs
aws logs tail /aws/lambda/bedrock-asset-processor
```

### View Metrics in CloudWatch Console
1. Open [CloudWatch Console](https://console.aws.amazon.com/cloudwatch/)
2. Navigate to "Container Insights" → "EKS Clusters"
3. Select `project-bedrock-cluster`

## Troubleshooting

### Common Issues

#### 1. Terraform Apply Fails
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify region is us-east-1
aws configure get region

# Check resource quotas
aws service-quotas list-service-quotas --service-code eks
```

#### 2. EKS Cluster Not Accessible
```bash
# Verify cluster exists
aws eks describe-cluster --name project-bedrock-cluster --region us-east-1

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name project-bedrock-cluster

# Check IAM permissions
aws sts get-caller-identity
```

#### 3. Pod Deployment Issues
```bash
# Check node status
kubectl get nodes

# Check pod events
kubectl describe pod [pod-name] -n retail-app

# Check resource availability
kubectl top nodes
kubectl top pods -n retail-app
```

#### 4. CloudWatch Logs Not Appearing
```bash
# Check if ClusterCloudWatch addon is installed
kubectl get pods -n amazon-cloudwatch

# Manually deploy FluentBit if needed
kubectl apply -f k8s-manifests/fluentbit.yaml
```

### Getting Help
1. Check pod logs: `kubectl logs [pod-name] -n retail-app`
2. Check events: `kubectl get events -n retail-app --sort-by=.metadata.creationTimestamp`
3. Verify security groups and IAM permissions
4. Check AWS CloudTrail for API call errors

## Cleanup

### Destroy Infrastructure
```bash
# Using Terraform
cd terraform
terraform destroy

# Manual cleanup if needed
# Delete EKS cluster
aws eks delete-cluster --name project-bedrock-cluster

# Delete VPC (wait for cluster deletion first)
# Delete S3 bucket
aws s3 rm s3://bedrock-assets-ALT-SOE-025-0223 --recursive
aws s3 rb s3://bedrock-assets-ALT-SOE-025-0223

# Delete Lambda function
aws lambda delete-function --function-name bedrock-asset-processor
```

### Cost Optimization Tips
1. **Use Spot Instances**: For non-production workloads
2. **Right-size Resources**: Monitor and adjust instance types
3. **Delete Unused Resources**: Regularly review and cleanup
4. **Set up Billing Alerts**: Monitor costs in CloudWatch

## Additional Resources

### AWS Documentation
- [EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [VPC User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

### Kubernetes Resources
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)

### Monitoring and Observability
- [Container Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html)
- [CloudWatch Agent Configuration](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html)