# VPC and Peering (Mini Project 2)

## 🎯 Overview

This demo showcases **AWS VPC Peering** by creating two VPCs in different AWS regions and establishing a peering connection between them. This allows resources in both VPCs to communicate with each other using private IP addresses.

## 🏗️ Architecture
```
┌─────────────────────────────────────┐       ┌─────────────────────────────────────┐
│     Primary VPC (us-east-1)         │       │    Secondary VPC (us-west-2)        │
│     CIDR: 10.0.0.0/16               │       │    CIDR: 10.1.0.0/16                │
│                                     │       │                                     │
│  ┌───────────────────────────────┐  │       │  ┌───────────────────────────────┐  │
│  │  Subnet: 10.0.1.0/24          │  │       │  │  Subnet: 10.1.1.0/24          │  │
│  │  ┌─────────────────────────┐  │  │       │  │  ┌─────────────────────────┐  │  │
│  │  │  EC2 Instance           │  │  │       │  │  │  EC2 Instance           │  │  │
│  │  │  Private IP: 10.0.1.x   │  │  │       │  │  │  Private IP: 10.1.1.x   │  │  │
│  │  └─────────────────────────┘  │  │       │  │  └─────────────────────────┘  │  │
│  └───────────────────────────────┘  │       │  └───────────────────────────────┘  │
│                                     │       │                                     │
│  Internet Gateway                   │       │  Internet Gateway                   │
└─────────────────┬───────────────────┘       └─────────────────┬───────────────────┘
                  │                                             │
                  └───────────────VPC Peering──────────────────┘
```

## 📦 Resources Created

### Networking Components
| Resource Type | Purpose | Region |
|---------------|---------|--------|
| AWS VPC | Primary VPC (10.0.0.0/16) | us-east-1 |
| AWS VPC | Secondary VPC (10.1.0.0/16) | us-west-2 |
| AWS Subnet | Public subnet in each VPC | Both |
| AWS Internet Gateway | Internet access for each VPC | Both |
| AWS Route Table | Routing with peering routes | Both |
| AWS VPC Peering Connection | Cross-region peering | Both |

### Compute Resources
| Resource Type | Purpose | Region |
|---------------|---------|--------|
| AWS Instance | EC2 t2.micro with Apache | us-east-1 |
| AWS Instance | EC2 t2.micro with Apache | us-west-2 |
| AWS Security Group | Firewall rules | Both |

## 🛠️ Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
3. **Terraform** installed (version >= 1.0)
4. **SSH Key Pair** created in both regions (use the same name)

### Creating SSH Key Pairs
```bash
# For us-east-1
aws ec2 create-key-pair --key-name vpc-peering-demo --region us-east-1 --query 'KeyMaterial' --output text > vpc-peering-demo.pem

# For us-west-2
aws ec2 create-key-pair --key-name vpc-peering-demo --region us-west-2 --query 'KeyMaterial' --output text > vpc-peering-demo-west.pem

# Set permissions (on Linux/Mac)
chmod 400 vpc-peering-demo.pem
```

## 🚀 Setup Instructions

### 1. Navigate to Project Directory
```bash
cd project_2/code
```

### 2. Configure Variables
Edit `terraform.tfvars` and add your key pair name:
```hcl
key_name = "vpc-peering-demo"
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Review the Plan
```bash
terraform plan
```

### 5. Apply the Configuration
```bash
terraform apply
```

Type `yes` when prompted.

## ✅ Testing VPC Peering

After the infrastructure is created, you can test the VPC peering connection:

### 1. Get Instance IPs
```bash
terraform output
```

### 2. Test Connectivity from Primary to Secondary
```bash
# SSH into Primary instance
ssh -i vpc-peering-demo.pem ec2-user@<PRIMARY_PUBLIC_IP>

# Ping the Secondary instance using its private IP
ping <SECONDARY_PRIVATE_IP>

# Test HTTP connectivity
curl http://<SECONDARY_PRIVATE_IP>
```

### 3. Test Connectivity from Secondary to Primary
```bash
# SSH into Secondary instance
ssh -i vpc-peering-demo.pem ec2-user@<SECONDARY_PUBLIC_IP>

# Ping the Primary instance using its private IP
ping <PRIMARY_PRIVATE_IP>

# Test HTTP connectivity
curl http://<PRIMARY_PRIVATE_IP>
```

## 📚 Key Concepts Demonstrated

### 1. VPC Peering
- Cross-region VPC peering connection
- Peering connection requester and accepter
- Automatic acceptance configuration

### 2. Routing
- Route tables with peering routes
- Traffic routing between VPCs
- Internet gateway routes

### 3. Security
- Security groups allowing cross-VPC traffic
- ICMP and TCP rules
- Proper egress rules

### 4. Multi-Region Deployment
- Using provider aliases for different regions
- Cross-region resource dependencies
- Regional AMI selection

## ⚠️ Important Notes

### CIDR Blocks
- VPC CIDR blocks **must not overlap** for peering to work
- Primary VPC: 10.0.0.0/16
- Secondary VPC: 10.1.0.0/16

### Costs
This demo creates resources that incur AWS charges:
- EC2 instances (t2.micro)
- Data transfer between regions
- VPC peering data transfer

**Remember to destroy resources when done:**
```bash
terraform destroy
```

### Limitations
- VPC peering is **not transitive** (if A peers with B, and B peers with C, A cannot communicate with C)
- VPC peering does not support **edge-to-edge routing**
- Maximum of **125** peering connections per VPC

## 🔧 Troubleshooting

### Cannot Connect Between Instances
1. Check security groups allow traffic from the peered VPC CIDR
2. Verify route tables have routes to the peered VPC
3. Ensure VPC peering connection is in "active" state
4. Check NACL rules (if configured)

### Peering Connection Not Accepting
1. Ensure auto_accept is set to true in accepter resource
2. Check IAM permissions for cross-region operations
3. Verify VPC CIDR blocks don't overlap

### SSH Connection Issues
1. Verify key pair exists in the correct region
2. Check security group allows SSH (port 22)
3. Ensure instance has a public IP address
4. Verify internet gateway and route table configuration

## 🧹 Cleanup

To avoid ongoing charges, destroy all resources:
```bash
terraform destroy
```

Type `yes` when prompted. This will remove:
- EC2 instances
- VPC peering connection
- Security groups
- Route tables
- Subnets
- Internet gateways
- VPCs

## 🎉 Learning Outcomes

After completing this demo, you will understand:
1. How to create VPC peering connections between regions
2. How to configure routing for VPC peering
3. How to set up security groups for cross-VPC communication
4. How to use Terraform provider aliases for multi-region deployments
5. How to test and verify VPC peering connectivity

## 🔗 Additional Resources

- [AWS VPC Peering Documentation](https://docs.aws.amazon.com/vpc/latest/peering/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [VPC Peering Best Practices](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html)

## 🚦 Next Steps

To extend this demo, you could:
1. Add more subnets (private subnets)
2. Implement NAT gateways
3. Add VPC Flow Logs for traffic analysis
4. Create additional EC2 instances
5. Set up a VPN connection
6. Implement Transit Gateway for complex topologies