# Terraform Projects

A collection of Terraform infrastructure projects demonstrating various AWS services and architectural patterns.

## 📚 Projects

### [Project 1: Static Website Hosting](/project_1/)
Deploy a static website on AWS using S3 and CloudFront.

**Features:**
- S3 static website hosting
- CloudFront CDN for global content delivery
- Public access configuration
- Modern responsive website with dark/light theme toggle

**Quick Start:**
```bash
cd project_1/code
terraform init
terraform apply
```

---

### [Project 2: VPC and Peering](/project_2/)
Learn AWS VPC Peering by creating two VPCs in different regions and connecting them.

**Features:**
- Cross-region VPC peering
- Multi-region deployment with provider aliases
- EC2 instances with Apache web servers
- Security groups for cross-VPC communication

**Quick Start:**
```bash
cd project_2/code
terraform init
terraform apply
```

---

### [Project 3: IAM User Management](/project_3/)
Manage AWS IAM users, groups, and memberships using Terraform with CSV data source.

**Features:**
- CSV-based user management
- Dynamic group membership based on user attributes
- Console access with password management
- Tag-based organization (Department, JobTitle)

**Quick Start:**
```bash
cd project_3/code
terraform init
terraform apply
```

---

### [Project 4: Blue-Green Deployment](/project_4/)

Zero-downtime deployment strategy using AWS Elastic Beanstalk with blue-green environments.

**Features:**

- Elastic Beanstalk application with two environments
- Blue environment (Production) - running v1.0
- Green environment (Staging) - running v2.0
- CNAME swap for instant traffic switching
- Easy rollback capability

**Quick Start:**

```bash
cd project_4/code
./package-apps.sh  # Linux/Mac or use package-apps.ps1 for Windows
terraform init
terraform apply
```

---

### [Project 5: Serverless Image Processing](/project_5/)

Automated image processing pipeline using Lambda, S3, and Pillow library.

**Features:**

- S3 event-triggered Lambda function
- Automated image optimization (JPEG, WebP, PNG)
- Multiple output variants (compressed, low-quality, thumbnail)
- Serverless architecture with automatic scaling
- Lambda layer with Pillow library

**Quick Start:**
```bash
cd project_5/code
./scripts/deploy.sh
```

---

### [React AWS Pipeline](/react_aws_pipeline/)

CI/CD pipeline for deploying React applications to AWS.

**Features:**

- CodePipeline for continuous delivery
- S3 bucket for website hosting
- CloudFront CDN distribution
- Lambda for cache invalidation

---

### [Bootstrap](/bootstrap/)

Initial Terraform backend configuration.

**Purpose:**
- Sets up S3 bucket for Terraform state storage

---

## 🛠️ Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version 1.0+)
- AWS Account with sufficient permissions

## 📖 Documentation

- [Dynamic State Bucket Documentation](/docs/dynamic_state_bucket.md)
- [Project 1: Static Website - System Design](/project_1/docs/DESIGN.md)
- [Project 2: VPC Peering - System Design](/project_2/docs/DESIGN.md)
- [Project 3: IAM User Management - System Design](/project_3/docs/DESIGN.md)
- [Project 4: Blue-Green Deployment - Architecture](/project_4/docs/ARCHITECTURE.md)
- [Project 5: Serverless Image Processing - Architecture](/project_5/docs/IMAGE_PROCESSING_ARCHITECTURE.md)

## 🚀 Getting Started

1. Clone this repository
2. Navigate to your desired project
3. Follow the README.md instructions in each project folder

## 📝 License

MIT License - See individual project folders for details.
