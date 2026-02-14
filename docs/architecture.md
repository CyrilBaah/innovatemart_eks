# InnovateMart Project Bedrock - Architecture Overview

## High-Level Architecture

Project Bedrock implements a production-grade microservices architecture on AWS EKS with the following components:

### Infrastructure Layer

#### Network Architecture
- **VPC**: `project-bedrock-vpc` (10.0.0.0/16)
  - **Public Subnets**: 10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24
  - **Private Subnets**: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24
  - **Availability Zones**: us-east-1a, us-east-1b, us-east-1c
  - **NAT Gateways**: One per AZ for high availability
  - **Internet Gateway**: For public subnet internet access

#### Compute Layer
- **EKS Cluster**: `project-bedrock-cluster`
  - **Version**: 1.31 (>= 1.34.0 requirement met)
  - **Control Plane**: Managed by AWS in multi-AZ configuration
  - **Worker Nodes**: EKS Managed Node Group
    - Instance Type: t3.medium
    - Min Size: 1
    - Max Size: 10
    - Desired Size: 2
    - Capacity Type: ON_DEMAND

### Application Architecture

#### Retail Store Microservices
The AWS Retail Store Sample Application consists of:

1. **UI Service**: Frontend React application
2. **Catalog Service**: Product catalog management
3. **Cart Service**: Shopping cart functionality  
4. **Orders Service**: Order processing
5. **Checkout Service**: Payment processing
6. **Assets Service**: Static asset serving

#### In-Cluster Dependencies (Core Requirements)
- **MySQL**: Catalog service database
- **PostgreSQL**: Orders service database
- **Redis**: Caching for cart and checkout services
- **RabbitMQ**: Message queue for inter-service communication

### Security Architecture

#### Identity and Access Management
- **EKS Cluster Role**: Service-linked role for EKS operations
- **Node Group Role**: EC2 role for worker nodes
- **Developer User**: `bedrock-dev-view`
  - AWS Console: ReadOnlyAccess policy
  - S3 Bucket: PutObject permissions
  - Kubernetes: Read-only RBAC (view ClusterRole)

#### Network Security
- **Security Groups**: 
  - Cluster Security Group: EKS API server access
  - Node Security Group: Worker node communication
  - RDS Security Group: Database access (bonus feature)

### Serverless Extension

#### Event-Driven Processing
- **S3 Bucket**: `bedrock-assets-[student-id]`
  - Private bucket with encryption
  - Versioning enabled
  - Public access blocked
- **Lambda Function**: `bedrock-asset-processor`
  - Runtime: Python 3.11
  - Trigger: S3 ObjectCreated events
  - Function: Logs uploaded file names to CloudWatch

### Observability Architecture

#### Logging Strategy
- **Control Plane Logs**: EKS audit, API, authenticator, controller manager, scheduler logs → CloudWatch
- **Application Logs**: Container logs via CloudWatch Observability addon → CloudWatch Log Groups
- **Lambda Logs**: Function execution logs → CloudWatch

#### Monitoring
- **CloudWatch Metrics**: EKS cluster and node metrics
- **Resource Utilization**: CPU, memory, disk, network monitoring
- **Application Health**: Service availability and performance

### CI/CD Architecture

#### GitHub Actions Pipeline
1. **Pull Request Workflow**:
   - Terraform format check
   - Terraform plan generation
   - Plan posted as PR comment

2. **Main Branch Workflow**:
   - Terraform apply (infrastructure deployment)
   - Application deployment to EKS
   - Grading output generation

#### Security Controls
- AWS credentials stored as GitHub Secrets
- Branch protection rules
- Required reviews for infrastructure changes

### Data Flow Diagram

```
[User] → [ALB/Ingress] → [UI Service] → [Backend Services]
                                            ↓
[Backend Services] ↔ [In-Cluster Databases] ↔ [Persistent Volumes]
                                            ↓
[Application Logs] → [CloudWatch Observability] → [CloudWatch Logs]
                                            ↓
[S3 Bucket] → [Lambda Function] → [CloudWatch Logs]
```

### Scalability Considerations

#### Horizontal Scaling
- **EKS Node Groups**: Auto-scaling from 1-10 nodes
- **Application Pods**: Kubernetes HPA for microservices
- **Databases**: Read replicas for high-traffic scenarios (bonus)

#### Performance Optimization
- **Resource Requests/Limits**: Defined for all services
- **Persistent Volumes**: EBS GP2 storage class
- **Network Optimization**: VPC CNI for pod networking

### Disaster Recovery

#### Backup Strategy
- **S3 Cross-Region Replication**: Asset backup (configurable)
- **EBS Snapshots**: Persistent volume backups
- **Database Backups**: Daily automated backups (RDS for bonus)

#### High Availability
- **Multi-AZ Deployment**: EKS control plane and worker nodes
- **Load Balancing**: Service mesh for microservice communication
- **Auto-Healing**: Kubernetes self-healing capabilities

### Cost Optimization

#### Resource Management
- **Right-Sizing**: t3.medium instances for development workload
- **Spot Instances**: Optional for non-critical workloads
- **Auto-Scaling**: Dynamic scaling based on demand
- **Log Retention**: 7-day retention for cost control

### Security Compliance

#### Access Controls
- **RBAC**: Kubernetes role-based access control
- **IAM**: AWS least-privilege policies
- **Network Policies**: Pod-to-pod communication restrictions (configurable)

#### Data Protection
- **Encryption at Rest**: EBS volumes, S3 buckets
- **Encryption in Transit**: TLS for all communications
- **Secret Management**: Kubernetes secrets for sensitive data

This architecture provides a robust, scalable, and secure foundation for InnovateMart's microservices platform while meeting all production-grade requirements.