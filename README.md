# InnovateMart EKS Infrastructure

A complete AWS EKS deployment with microservices application using Infrastructure as Code.

## Overview

This project deploys a production-ready EKS cluster with the AWS Retail Store Sample App using Terraform and GitHub Actions.

## Quick Start

### Prerequisites
- AWS CLI configured
- GitHub repository with AWS secrets

### Deploy Infrastructure
1. Go to **GitHub Actions**
2. Run **"Deploy Infrastructure (Terraform) - MANUAL ONLY"** workflow

### Deploy Application  
1. Run **"Deploy Application (Kubernetes) - MANUAL ONLY"** workflow
2. Access application via LoadBalancer URL

### Destroy Everything
1. Run **"Destroy Infrastructure (Terraform)"** workflow
2. Type `DESTROY` to confirm

## What's Included

- **EKS Cluster** (project-bedrock-cluster) with 2 SPOT instances
- **VPC** with public/private subnets
- **10 Microservices** retail store application
- **Load Balancer** for external access
- **S3 + DynamoDB** for Terraform state
- **Lambda Function** for asset processing

## Application

This project deploys the **AWS Retail Store Sample App** - a cloud-native microservices application that demonstrates modern application architecture patterns on AWS.

**Source:** https://github.com/aws-containers/retail-store-sample-app

The retail store includes:
- **Product Catalog** - Browse and search products
- **Shopping Cart** - Add/remove items 
- **User Accounts** - Customer registration and login
- **Checkout Process** - Order placement and payment
- **Inventory Management** - Stock tracking across services
- **Microservices Architecture** - Independent, scalable components
