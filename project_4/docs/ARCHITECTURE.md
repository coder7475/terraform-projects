# Project 4: AWS Elastic Beanstalk Blue-Green Deployment Architecture

## Overview

This document provides a comprehensive architectural overview of Project 4, a Terraform-based infrastructure for implementing **zero-downtime deployments** using AWS Elastic Beanstalk's blue-green deployment pattern. The architecture replicates the deployment slot functionality commonly found in Azure App Service, enabling seamless traffic switching between two identical environments.

---

## Architectural Principles

### Blue-Green Deployment Strategy

The blue-green deployment pattern maintains two identical production environments:

- **Blue Environment (Production)**: Currently serving live traffic with Application v1.0
- **Green Environment (Staging)**: Running the new version (v2.0) for testing before going live

This approach provides:
- **Instant Rollback**: Simply swap CNAMEs to revert to the previous version
- **Zero Downtime**: Traffic switches at DNS level with no service interruption
- **Production Parity**: Both environments run on identical infrastructure

---

## High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AWS Elastic Beanstalk                                │
│                         Application: bg-deployment                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────┐    ┌─────────────────────────────┐         │
│  │     BLUE ENVIRONMENT        │    │     GREEN ENVIRONMENT       │         │
│  │     (Production - v1.0)     │    │     (Staging - v2.0)        │         │
│  ├─────────────────────────────┤    ├─────────────────────────────┤         │
│  │                             │    │                             │         │
│  │  ┌───────────────────────┐  │    │  ┌───────────────────────┐  │         │
│  │  │  Application Load    │  │    │  │  Application Load    │  │         │
│  │  │  Balancer (ALB)      │  │    │  │  Balancer (ALB)       │  │         │
│  │  └───────────────────────┘  │    │  └───────────────────────┘  │         │
│  │            │               │    │            │                │         │
│  │  ┌─────────┴─────────────┐ │    │  ┌─────────┴─────────────┐ │         │
│  │  │     Auto Scaling      │ │    │  │     Auto Scaling      │ │         │
│  │  │     Group (1-2)       │ │    │  │     Group (1-2)       │ │         │
│  │  └─────────┬─────────────┘ │    │  └─────────┬─────────────┘ │         │
│  │            │               │    │            │                │         │
│  │  ┌─────────┴─────────────┐ │    │  ┌─────────┴─────────────┐ │         │
│  │  │  EC2 Instances        │ │    │  │  EC2 Instances       │ │         │
│  │  │  (t3.micro)           │ │    │  │  (t3.micro)          │ │         │
│  │  │  Node.js 20           │ │    │  │  Node.js 20          │ │         │
│  │  └───────────────────────┘ │    │  └───────────────────────┘ │         │
│  │                             │    │                             │         │
│  │  CNAME: bg-deployment-blue │    │  CNAME: bg-deployment-green │         │
│  │  .elasticbeanstalk.com     │    │  .elasticbeanstalk.com      │         │
│  └─────────────────────────────┘    └─────────────────────────────┘         │
│                │                                    │                        │
│                └──────────────┬─────────────────────┘                        │
│                               │                                               │
│                    ┌──────────▼──────────┐                                   │
│                    │   CNAME Swap        │                                   │
│                    │   (Instant DNS)     │                                   │
│                    └──────────┬──────────┘                                   │
│                               │                                               │
│                               ▼                                               │
│                    ┌──────────────────────┐                                  │
│                    │    End Users         │                                  │
│                    └──────────────────────┘                                  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                           Supporting Services                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────┐ │
│  │   IAM Roles         │    │   S3 Bucket         │    │  CloudWatch     │ │
│  │   - EC2 Instance    │    │   (app versions)    │    │  (Enhanced      │ │
│  │     Profile         │    │   - app-v1.zip      │    │   Health        │ │
│  │   - Service Role    │    │   - app-v2.zip      │    │   Reporting)    │ │
│  └─────────────────────┘    └─────────────────────┘    └─────────────────┘ │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Component Architecture

### 1. Elastic Beanstalk Application

| Component | Description | Configuration |
|-----------|-------------|---------------|
| **Application Name** | `bg-deployment` | Configurable via `var.app_name` |
| **Description** | Blue-Green Deployment Demo Application | - |
| **Platform** | Node.js 20 on Amazon Linux 2023 | `64bit Amazon Linux 2023 v6.6.8 running Node.js 20` |

### 2. Blue Environment (Production)

The Blue environment serves as the primary production environment running Application v1.0.

**Infrastructure Components:**

| Resource | Type | Details |
|----------|------|---------|
| **Environment Name** | Elastic Beanstalk Environment | `bg-deployment-blue` |
| **Version** | Application Version | `bg-deployment-v1` |
| **Application Version** | S3 Object | `app-v1.zip` |
| **Tier** | WebServer | Standard Elastic Beanstalk tier |
| **Instance Type** | EC2 | `t3.micro` (configurable) |
| **Load Balancer** | Application Load Balancer | HTTP on port 8080 |
| **Auto Scaling** | ASG | Min: 1, Max: 2 instances |
| **Health Check** | HTTP | Path: `/` |
| **Deployment Policy** | Rolling | 50% batch size |
| **Environment Variables** | Key-Value | `ENVIRONMENT=blue`, `VERSION=1.0` |

**Tags:**
```
Environment: blue
Role: production
Project: BlueGreenDeployment
ManagedBy: Terraform
```

### 3. Green Environment (Staging)

The Green environment runs Application v2.0 for pre-production testing before swapping.

**Infrastructure Components:**

| Resource | Type | Details |
|----------|------|---------|
| **Environment Name** | Elastic Beanstalk Environment | `bg-deployment-green` |
| **Version** | Application Version | `bg-deployment-v2` |
| **Application Version** | S3 Object | `app-v2.zip` |
| **Tier** | WebServer | Standard Elastic Beanstalk tier |
| **Instance Type** | EC2 | `t3.micro` (configurable) |
| **Load Balancer** | Application Load Balancer | HTTP on port 8080 |
| **Auto Scaling** | ASG | Min: 1, Max: 2 instances |
| **Health Check** | HTTP | Path: `/` |
| **Deployment Policy** | Rolling | 50% batch size |
| **Environment Variables** | Key-Value | `ENVIRONMENT=green`, `VERSION=2.0` |

**Tags:**
```
Environment: green
Role: staging
Project: BlueGreenDeployment
ManagedBy: Terraform
```

### 4. IAM Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        IAM Role Hierarchy                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    EB EC2 Role                           │   │
│  │    Role Name: bg-deployment-eb-ec2-role                 │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  Attached Policies:                                     │   │
│  │  • AWSElasticBeanstalkWebTier                           │   │
│  │  • AWSElasticBeanstalkWorkerTier                        │   │
│  │  • AWSElasticBeanstalkMulticontainerDocker              │   │
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                       │
│                           ▼                                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │               EB EC2 Instance Profile                    │   │
│  │    Profile Name: bg-deployment-eb-ec2-profile           │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                  EB Service Role                         │   │
│  │    Role Name: bg-deployment-eb-service-role             │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  Attached Policies:                                      │   │
│  │  • AWSElasticBeanstalkEnhancedHealth                    │   │
│  │  • AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 5. S3 Storage Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      S3 Bucket Architecture                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Bucket: bg-deployment-versions-<account-id>                    │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                                                         │    │
│  │  ┌─────────────────┐    ┌─────────────────┐          │    │
│  │  │   app-v1.zip    │    │   app-v2.zip    │          │    │
│  │  │   (Blue - v1.0) │    │   (Green - v2.0)│          │    │
│  │  └─────────────────┘    └─────────────────┘          │    │
│  │                                                         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  Security:                                                      │
│  • Public Access Blocked                                        │
│  • ACLs Disabled                                                │
│  • Bucket Policy Restricted                                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Flow

### Deployment Flow

```
1. Package Application
   ┌─────────────────┐
   │  app-v1/v2.zip  │
   └────────┬────────┘
            │
            ▼
2. Upload to S3
   ┌─────────────────────────────────────────┐
   │  aws_s3_object (app_v1 / app_v2)        │
   │  Bucket: bg-deployment-versions-***    │
   └────────┬────────────────────────────────┘
            │
            ▼
3. Create Application Version
   ┌─────────────────────────────────────────────────┐
   │  aws_elastic_beanstalk_application_version     │
   │  v1: bg-deployment-v1                           │
   │  v2: bg-deployment-v2                           │
   └────────┬────────────────────────────────────────┘
            │
            ▼
4. Deploy to Environment
   ┌────────────────────────────────────────────────────┐
   │  aws_elastic_beanstalk_environment                │
   │  blue: bg-deployment-blue  (v1)                   │
   │  green: bg-deployment-green (v2)                  │
   └────────┬───────────────────────────────────────────┘
            │
            ▼
5. Health Check & Load Balancing
   ┌────────────────────────────────────────────────────┐
   │  ALB → Auto Scaling Group → EC2 Instances        │
   │  Health Check: HTTP GET /                          │
   └────────────────────────────────────────────────────┘
```

### Traffic Switch Flow (CNAME Swap)

```
Before Swap:
┌────────────────────────────────────────────────────────────┐
│  User Traffic ──► blue URL ──► Blue Env (v1.0)           │
│                    green URL ──► Green Env (v2.0)         │
└────────────────────────────────────────────────────────────┘

AWS CLI Command:
aws elasticbeanstalk swap-environment-cnames \
  --source-environment-name bg-deployment-blue \
  --destination-environment-name bg-deployment-green \
  --region ap-southeast-1

After Swap:
┌────────────────────────────────────────────────────────────┐
│  User Traffic ──► blue URL ──► Green Env (v2.0) ◄─┐     │
│                    green URL ──► Blue Env (v1.0) ──┘     │
└────────────────────────────────────────────────────────────┘
```

---

## Network Architecture

### Security Groups

| Environment | Inbound Rules | Outbound Rules |
|-------------|---------------|----------------|
| Blue | HTTP (80) → ALB, HTTPS (443) → ALB | All → Internet |
| Green | HTTP (80) → ALB, HTTPS (443) → ALB | All → Internet |

### Subnet Configuration

- Uses default VPC subnets for EC2 instances
- Application Load Balancer placed in public subnets
- EC2 instances placed in private subnets

---

## Configuration Management

### Terraform Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `ap-southeast-1` | AWS region for resources |
| `app_name` | string | `bg-deployment` | Elastic Beanstalk application name |
| `env` | string | `development` | Environment identifier |
| `solution_stack_name` | string | `64bit Amazon Linux 2023 v6.6.8 running Node.js 20` | Platform version |
| `instance_type` | string | `t3.micro` | EC2 instance type |
| `tags` | map(string) | See below | Resource tags |

**Default Tags:**
```hcl
{
  Project     = "BlueGreenDeployment"
  Environment = "Demo"
  ManagedBy   = "Terraform"
}
```

---

## Deployment Policies

### Rolling Deployment

| Setting | Value | Description |
|---------|-------|-------------|
| Deployment Policy | `Rolling` | Updates instances in batches |
| Batch Size Type | `Percentage` | Size expressed as percentage |
| Batch Size | `50` | 50% of instances per batch |
| Min Instances in Service | Auto | Maintained by EB |

### Health Monitoring

- **Enhanced Health Reporting**: Enabled
- **Health Check Path**: `/`
- **Health Check Port**: `8080`
- **Health Check Protocol**: HTTP
- **Instance Health Threshold**: OK status required

---

## Operational Procedures

### Deployment Workflow

1. **Package Applications**: Create `app-v1.zip` and `app-v2.zip`
2. **Initialize Terraform**: `terraform init`
3. **Plan Infrastructure**: `terraform plan`
4. **Deploy**: `terraform apply`
5. **Verify Blue (Production)**: Visit Blue URL, confirm v1.0
6. **Verify Green (Staging)**: Visit Green URL, confirm v2.0
7. **Test New Version**: Validate v2.0 in Green environment
8. **Swap Traffic**: Run CNAME swap command
9. **Verify Production**: Confirm v2.0 now serves on Blue URL

### Rollback Procedure

Simply execute the CNAME swap again to revert traffic to the previous environment. No redeployment required.

```bash
aws elasticbeanstalk swap-environment-cnames \
  --source-environment-name bg-deployment-blue \
  --destination-environment-name bg-deployment-green \
  --region ap-southeast-1
```

---

## Cost Analysis

### Resource Costs (Monthly Estimates)

| Resource | Quantity | Estimated Cost |
|----------|----------|-----------------|
| Application Load Balancer | 2 | ~$32/month |
| EC2 Instances (t3.micro) | 2-4 | ~$15-30/month |
| S3 Storage | ~10 MB | ~$0.50/month |
| Data Transfer | Variable | ~$5-10/month |
| **Total** | - | **$50-75/month** |

### Cost Optimization Strategies

1. **Use t3.micro instances** (default) for development
2. **Set appropriate auto-scaling limits** (Min: 1, Max: 2)
3. **Destroy resources when not in use**: `terraform destroy`
4. **Use spot instances** for non-production environments

---

## Disaster Recovery

### Backup Strategy

- Application versions stored in S3 with versioning
- Terraform state maintains infrastructure configuration
- Both environments are identical, providing mutual backup

### Recovery Procedures

| Scenario | Recovery Action |
|----------|-----------------|
| Green Env fails | Continue using Blue (production) |
| Blue Env fails | Swap to Green environment |
| Complete failure | Deploy to new environment from S3 versions |

---

## Security Considerations

### IAM Best Practices

- **Least Privilege**: EC2 instances only receive necessary managed policies
- **Role Separation**: Distinct roles for EC2 and service
- **No Credentials**: No access keys stored in infrastructure

### Network Security

- **Private Subnets**: EC2 instances in private subnets
- **Security Groups**: Restrictive inbound rules
- **HTTPS**: Can be added via ACM certificate

### S3 Security

- **Public Access Blocked**: Prevents unauthorized downloads
- **Bucket Policy**: Restricts access to EB service only

---

## Monitoring and Observability

### CloudWatch Integration

- **Enhanced Health Reporting**: Real-time environment health
- **Auto Scaling Events**: Scale up/down notifications
- **Application Logs**: Available via EB console or CLI

### Health Check Configuration

```yaml
Health Check Path: /
Health Check Port: 8080
Protocol: HTTP
Timeout: 5 seconds
Interval: 10 seconds
Unhealthy Threshold: 5
Healthy Threshold: 3
```

---

## Scalability

### Auto Scaling Configuration

| Parameter | Value | Description |
|-----------|-------|-------------|
| Minimum Size | 1 | Minimum instances running |
| Maximum Size | 2 | Maximum instances under load |
| Scaling Metric | CPU Utilization | Trigger: >80% for 5 minutes |

### Scaling Behavior

- **Scale Out**: When CPU > 80% for 5 consecutive minutes
- **Scale In**: When CPU < 30% for 5 consecutive minutes
- **Instance Replacement**: On health failures

---

## Comparison with Azure App Service

| Feature | Azure App Service | AWS Elastic Beanstalk |
|---------|-------------------|----------------------|
| **Service Type** | PaaS | PaaS |
| **Slot Management** | Native Deployment Slots | Separate Environments |
| **Swap Mechanism** | Slot Swap | CNAME Swap |
| **Swap Speed** | Instant | 1-2 minutes |
| **Instance Sharing** | Yes (across slots) | No (separate ASGs) |
| **Rollback** | One-click swap | One-click swap |
| **Cost Model** | Per slot | Per environment |

---

## File Structure

```
project_4/
├── README.md                          # User guide and quick start
├── doc/                               # Documentation (empty)
├── code/
│   ├── main.tf                        # Core infrastructure
│   ├── variables.tf                   # Input variables
│   ├── outputs.tf                     # Output values
│   ├── backend.tf                     # Terraform backend
│   ├── provider.tf                    # AWS provider config
│   ├── blue-environment.tf           # Blue environment config
│   ├── green-environment.tf           # Green environment config
│   ├── app-v1/
│   │   ├── app.js                     # Node.js app v1.0
│   │   ├── package.json               # Dependencies v1
│   │   └── package-lock.json          # Lock file
│   └── app-v2/
│       ├── app.js                     # Node.js app v2.0
│       ├── package.json               # Dependencies v2
│       └── package-lock.json          # Lock file
```

---

## Conclusion

This architecture provides a robust, production-ready blue-green deployment solution using AWS Elastic Beanstalk and Terraform. The key benefits include:

1. **Zero-Downtime Deployments**: Instant traffic switching
2. **Risk Mitigation**: Easy rollback capability
3. **Infrastructure as Code**: Fully automated provisioning
4. **Cost-Effective**: Pay only for running environments
5. **Scalable**: Auto-scaling built-in

---

*Document Version: 1.0*  
*Last Updated: 2026-03-07*  
*Author: Documentation Specialist*
