## Understanding the Challenge

There's a "chicken-and-egg" problem: you need Terraform state to store Terraform state. Here are the solutions:

## Solution 1: Manual Bucket Creation (Quick Start)

Create the S3 bucket manually or via CLI, then configure Terraform to use it:

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "project-name/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

## Solution 2: Dynamic Bucket Creation (Using Terragrunt)

[Terragrunt](https://terragrunt.gruntwork.io/) is designed for this pattern:

```hcl
# terragrunt.hcl
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents = <<EOF
terraform {
  backend "s3" {
    bucket         = "${get_env("BUCKET_NAME")}"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
EOF
}

inputs = {
  bucket_name = "my-unique-state-bucket-${random_id.suffix.hex}"
}
```

## Solution 3: Two-Stage Terraform Approach

**Stage 1:** Create the bucket and lock table first:

```hcl
# stage1-backend/main.tf
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bucket-${var.environment}"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

**Stage 2:** Use the bucket as backend:

```hcl
# stage2-app/main.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-prod"
    key            = "app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks-prod"
  }
}
```

## Solution 4: Using Terraform Cloud/State

Instead of managing your own bucket, use [Terraform Cloud](https://www.terraform.io/cloud) or [Terraform Enterprise](https://www.terraform.io/enterprise) which provides state management out of the box.

```hcl
terraform {
  cloud {
    organization = "my-org"
    workspaces {
      name = "my-workspace"
    }
  }
}
```

## Best Practices

| Practice | Reason |
|----------|--------|
| **Enable versioning** | Allows state recovery from accidental deletions |
| **Enable encryption** | Protects sensitive state data at rest |
| **Use DynamoDB locking** | Prevents concurrent modifications |
| **Restrict access with IAM** | Follow principle of least privilege |
| **Enable bucket versioning** | State history and rollback capability |

## Complete Example with Outputs

Here's a complete setup that creates the backend infrastructure:

```hcl
# backend-setup.tf
variable "environment" {
  default = "prod"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-${var.environment}-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "backend_config" {
  value = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.id}"
        key            = "terraform.tfstate"
        region         = "${data.aws_region.current.name}"
        encrypt        = true
        dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"
      }
    }
  EOT
}
```

The recommended approach is **Terragrunt** (Solution 2) or **two-stage Terraform** (Solution 3) for production environments, as they handle the bootstrap problem elegantly while maintaining state isolation and best practices.