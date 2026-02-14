#!/bin/bash
# Fix EBS CSI Driver IAM permissions

CLUSTER_NAME="project-bedrock-cluster"
REGION="us-east-1"
ADDON_NAME="aws-ebs-csi-driver"

echo "Fixing EBS CSI Driver IAM permissions..."

# Get cluster and account information
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
OIDC_ISSUER=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query "cluster.identity.oidc.issuer" --output text)
OIDC_ID=$(echo $OIDC_ISSUER | cut -d '/' -f 5)

echo "Account ID: $ACCOUNT_ID"
echo "OIDC Issuer: $OIDC_ISSUER"
echo "OIDC ID: $OIDC_ID"

# Create trust policy for EBS CSI driver
cat > ebs-csi-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$ACCOUNT_ID:oidc-provider/oidc.eks.$REGION.amazonaws.com/id/$OIDC_ID"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.$REGION.amazonaws.com/id/$OIDC_ID:aud": "sts.amazonaws.com",
          "oidc.eks.$REGION.amazonaws.com/id/$OIDC_ID:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF

# Create IAM role for EBS CSI driver
ROLE_NAME="AmazonEKS_EBS_CSI_DriverRole_$CLUSTER_NAME"

echo "Creating IAM role: $ROLE_NAME"
aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://ebs-csi-trust-policy.json \
  --description "Amazon EKS - EBS CSI Driver Role for $CLUSTER_NAME"

# Attach the AWS managed policy
echo "Attaching EBS CSI policy to role..."
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy

# Update the EKS addon with the service account role
echo "Updating EBS CSI addon with service account role..."
aws eks update-addon \
  --cluster-name $CLUSTER_NAME \
  --addon-name $ADDON_NAME \
  --service-account-role-arn arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME \
  --region $REGION \
  --resolve-conflicts OVERWRITE

echo "EBS CSI Driver fix initiated. The addon will restart with proper permissions."
echo "Check status with: kubectl get pods -n kube-system | grep ebs-csi"

# Clean up
rm -f ebs-csi-trust-policy.json