#!/bin/bash

set -e

CLUSTER_NAME="project-bedrock-cluster"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "Creating EBS CSI Controller IAM Role..."
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
echo "Account: $ACCOUNT_ID"

# Get OIDC issuer URL
OIDC_ISSUER_URL=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query "cluster.identity.oidc.issuer" --output text)
OIDC_ID=$(echo $OIDC_ISSUER_URL | cut -d '/' -f 5)

echo "OIDC Issuer: $OIDC_ISSUER_URL"
echo "OIDC ID: $OIDC_ID"

# Create IAM role trust policy
cat > /tmp/aws-ebs-csi-driver-trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/oidc.eks.${REGION}.amazonaws.com/id/${OIDC_ID}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.${REGION}.amazonaws.com/id/${OIDC_ID}:aud": "sts.amazonaws.com",
          "oidc.eks.${REGION}.amazonaws.com/id/${OIDC_ID}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF

# Create the IAM role
ROLE_NAME="AmazonEKS_EBS_CSI_DriverRole"
echo "Creating IAM role: $ROLE_NAME"

aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file:///tmp/aws-ebs-csi-driver-trust-policy.json \
  --description "Amazon EKS - EBS CSI Driver Role" || echo "Role might already exist"

# Attach the required AWS managed policy
echo "Attaching EBS CSI policy to role..."
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy

# Annotate the service account with the role ARN
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
echo "Annotating service account with role: $ROLE_ARN"

kubectl annotate serviceaccount ebs-csi-controller-sa \
  -n kube-system \
  eks.amazonaws.com/role-arn=$ROLE_ARN \
  --overwrite

# Restart the EBS CSI controller deployment to pick up the new service account
echo "Restarting EBS CSI controller deployment..."
kubectl rollout restart deployment ebs-csi-controller -n kube-system

echo "Waiting for deployment to be ready..."
kubectl rollout status deployment ebs-csi-controller -n kube-system --timeout=300s

echo "EBS CSI Controller setup completed!"
echo "Checking pod status..."
kubectl get pods -n kube-system -l app=ebs-csi-controller

# Clean up temporary file
rm -f /tmp/aws-ebs-csi-driver-trust-policy.json