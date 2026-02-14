#!/bin/bash

# Deploy Retail Store Sample Application to EKS
# This script deploys the AWS retail-store-sample-app using Helm

set -e

NAMESPACE="retail-app"
RELEASE_NAME="retail-store"
CHART_REPO="aws"
CHART_NAME="aws-for-fluent-bit"
RETAIL_CHART_URL="https://aws.github.io/eks-charts"

echo "=== Deploying Retail Store Sample Application ==="

# Check if kubectl is configured for the cluster
echo "Checking kubectl configuration..."
kubectl cluster-info

# Create namespace
echo "Creating namespace: $NAMESPACE"
kubectl apply -f namespace.yaml

# Add the EKS charts repository
echo "Adding AWS EKS Helm repository..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Deploy the retail store application
echo "Deploying retail store application..."

# First, let's check if the retail store chart is available
# If not, we'll deploy using the official retail store chart
helm repo add retail-store https://aws.github.io/retail-store-sample-app
helm repo update

# Deploy the application
helm upgrade --install $RELEASE_NAME retail-store/retail-store-sample-app \
  --namespace $NAMESPACE \
  --create-namespace \
  --values values.yaml \
  --wait \
  --timeout 10m

# Verify deployment
echo "Verifying deployment..."
kubectl get pods -n $NAMESPACE
kubectl get services -n $NAMESPACE

echo "=== Deployment Complete ==="
echo "To access the application:"
echo "kubectl port-forward -n $NAMESPACE svc/ui 8080:80"
echo "Then open http://localhost:8080 in your browser"