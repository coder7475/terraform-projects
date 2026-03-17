# Image Processing Pipeline - AWS Architecture

## Overview

This document describes the AWS serverless architecture for an automated image processing pipeline. The system processes uploaded images and generates multiple optimized variants using AWS Lambda functions triggered by S3 events.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud                                          │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                         VPC (Optional)                                   │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐   │   │
│  │  │                                                                 │   │   │
│  │  │   ┌──────────────┐                     ┌──────────────────────┐  │   │   │
│  │  │   │   Upload S3  │                     │   Processed S3      │  │   │   │
│  │  │   │    Bucket    │                     │      Bucket         │  │   │   │
│  │  │   │              │                     │                     │  │   │   │
│  │  │   │ ┌──────────┐ │  s3:ObjectCreated   │ ┌────────────────┐ │  │   │   │
│  │  │   │ │  .jpg   │ │ ──────────────────▶  │ │ _compressed.jpg │ │  │   │   │
│  │  │   │ │  .png   │ │        event         │ │ _low.jpg       │ │  │   │   │
│  │  │   │ │  .webp  │ │                     │ │ _webp.webp     │ │  │   │   │
│  │  │   │ └──────────┘ │                     │ │ _png.png       │ │  │   │   │
│  │  │   │              │                     │ │ _thumb.jpg     │ │  │   │   │
│  │  │   │   ▲          │                     │ └────────────────┘ │  │   │   │
│  │  │   │   │          │                     │                     │  │   │   │
│  │  │   │   │ uploads  │                     │ ▲                  │  │   │   │
│  │  │   └───┼──────────┘                     │ │ writes           │  │   │   │
│  │  │       │          │                     └─┼──────────────────┘  │   │   │
│  │  │       │          │                     │                     │  │   │   │
│  │  │       │          │                     │                     │  │   │   │
│  │  │   ┌───┴──────────┴─────────────────────┴─────────────────────┐ │   │   │
│  │  │   │                                                            │ │   │   │
│  │  │   │              Lambda Function: image-processor            │ │   │   │
│  │  │   │  ┌──────────────────────────────────────────────────┐   │ │   │   │
│  │  │   │  │  Runtime: Python 3.12                            │   │ │   │   │
│  │  │   │  │  Memory: 1024 MB                                 │   │ │   │   │
│  │  │   │  │  Timeout: 60 seconds                             │   │ │   │   │
│  │  │   │  │  Layer: Pillow 10.4.0                            │   │ │   │   │
│  │  │   │  │                                                  │   │ │   │   │
│  │  │   │  │  ┌─────────────────────────────────────────┐    │   │ │   │   │
│  │  │   │  │  │         Image Processing               │    │   │ │   │   │
│  │  │   │  │  │  1. Download original from S3          │    │   │ │   │   │
│  │  │   │  │  │  2. Create 5 variants                   │    │   │ │   │   │
│  │  │   │  │  │  3. Upload variants to processed bucket │    │   │ │   │   │
│  │  │   │  │  │  4. Return success/failure              │    │   │ │   │   │
│  │  │   │  │  └─────────────────────────────────────────┘    │   │ │   │   │
│  │  │   │  └──────────────────────────────────────────────────┘   │ │   │   │
│  │  │   │                                                            │ │   │   │
│  │  │   └────────────────────────────────────────────────────────────┘ │   │   │
│  │  │                                                                    │   │   │
│  │  └────────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                              │
│  └──────────────────────────────────────────────────────────────────────────────┘
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐ │
│  │                        AWS CloudWatch                                     │ │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────┐   │ │
│  │  │   Log Groups    │  │  Metrics        │  │  Alarms                │   │ │
│  │  │ /aws/lambda/*   │  │ - Invocations   │  │ - Error rate > 5%      │   │ │
│  │  │                 │  │ - Duration      │  │ - Duration > 30s       │   │ │
│  │  │                 │  │ - Errors        │  │ - Throttling           │   │ │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────────────┘   │ │
│  └───────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐ │
│  │                        AWS IAM                                            │ │
│  │  ┌─────────────────────────────────────────────────────────────────────┐  │ │
│  │  │  Lambda Execution Role                                              │  │ │
│  │  │  - s3:GetObject (upload bucket)                                     │  │ │
│  │  │  - s3:PutObject (processed bucket)                                  │  │ │
│  │  │  - logs:CreateLogGroup                                              │  │ │
│  │  │  - logs:PutLogEvents                                                │  │ │
│  │  └─────────────────────────────────────────────────────────────────────┘  │ │
│  └───────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘

                              │
                              │ AWS CLI / SDK
                              │ (Application Upload)
                              ▼
                    ┌─────────────────────┐
                    │   Client Application │
                    │   or Developer       │
                    └─────────────────────┘
```

## AWS Services Used

| Service | Purpose | Configuration |
|---------|---------|---------------|
| **Amazon S3** | Storage for original and processed images | 2 buckets with SSE-S3 encryption |
| **AWS Lambda** | Serverless compute for image processing | Python 3.12, 1024 MB memory |
| **Amazon CloudWatch** | Logging, monitoring, and alerting | Logs retention: 30 days |
| **AWS IAM** | Access control and least privilege | Lambda execution role |

## Component Details

### 1. S3 Buckets

#### Upload Bucket (`image-upload-{region}-{account}`)

- **Purpose**: Storage location for original images
- **Configuration**:
  - Versioning: Enabled
  - Server-side encryption: AES-256
  - Block public access: Enabled
  - Lifecycle policy: Archive after 90 days (optional)

#### Processed Bucket (`image-processed-{region}-{account}`)

- **Purpose**: Storage location for processed image variants
- **Configuration**:
  - Versioning: Enabled
  - Server-side encryption: AES-256
  - Block public access: Enabled
  - Lifecycle policy: Delete old variants after 365 days

### 2. Lambda Function

#### Function: `image-processor`

| Property | Value |
|----------|-------|
| Runtime | Python 3.12 |
| Memory | 1024 MB |
| Timeout | 60 seconds |
| Concurrency | 10 (configurable) |
| Architecture | x86_64 |

#### Lambda Layer
- **Name**: `image-processing-layer`
- **Content**: Pillow 10.4.0 library

#### Environment Variables
```bash
PROCESSED_BUCKET    # Target bucket name
LOG_LEVEL          # Logging level (INFO, DEBUG)
```

### 3. Event Trigger

**Type**: S3 Event Notification

```json
{
  "Event": "s3:ObjectCreated:*",
  "Bucket": "image-upload-{region}-{account}"
}
```

#### Supported Input Formats
- JPEG (.jpg, .jpeg)
- PNG (.png)
- WebP (.webp)
- GIF (.gif)
- BMP (.bmp)

## Data Flow

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Data Flow Sequence                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

  Step 1                    Step 2                    Step 3
  ┌─────────┐              ┌─────────┐              ┌─────────┐
  │ Client  │              │   S3    │              │ Lambda  │
  │ Uploads │              │ Upload  │              │ Trigger │
  │  Image  │──────▶       │ Bucket  │──────▶       │         │
  └─────────┘              └─────────┘              └────┬────┘
                                                          │
                                                          ▼
  Step 6                    Step 5                    Step 4
  ┌─────────┐              ┌─────────┐              ┌─────────┐
  │ Cloud   │              │   S3    │              │ Process │
  │ Watch   │◀─────────    │ Process │◀──────────   │  Image  │
  │ Logs    │              │ Bucket  │              └─────────┘
  └─────────┘              └─────────┘
```

### Detailed Flow

1. **Image Upload**: Client uploads image to S3 upload bucket using AWS CLI/SDK
2. **Event Trigger**: S3 detects `ObjectCreated` event and invokes Lambda function
3. **Processing**: Lambda function:
   - Downloads original image from upload bucket
   - Creates 5 variants using Pillow library
   - Uploads each variant to processed bucket
   - Returns success/failure status
4. **Logging**: All processing details logged to CloudWatch Logs
5. **Monitoring**: CloudWatch metrics capture invocation count, duration, and errors

## Generated Variants

For each uploaded image, the system generates:

| Variant | Format | Quality/Dimensions | Use Case |
|---------|--------|---------------------|----------|
| Compressed | JPEG | 85% quality | Web display, balance of quality/size |
| Low Quality | JPEG | 60% quality | Mobile, slow connections |
| WebP | WebP | 85% quality | Modern browsers, best compression |
| PNG | PNG | Lossless | Transparency needed, editing |
| Thumbnail | JPEG | 200×200 px | Previews, thumbnails |

### Naming Convention

```
original:     my-photo.jpg
variants:
  my-photo_compressed_abc123.jpg
  my-photo_low_abc123.jpg
  my-photo_webp_abc123.webp
  my-photo_png_abc123.png
  my-photo_thumbnail_abc123.jpg
```

## Security Architecture

### IAM Role & Permissions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::image-upload-*/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::image-processed-*/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
```

### Security Features

| Feature | Implementation |
|---------|----------------|
| Encryption at Rest | AES-256 (S3 default) |
| Encryption in Transit | TLS 1.2+ (AWS default) |
| Public Access | Blocked on all buckets |
| Bucket Versioning | Enabled for both buckets |
| Least Privilege IAM | Specific bucket permissions only |
| VPC Isolation | Optional (not enabled by default) |

## Scalability & Performance

### Concurrency Settings

```hcl
resource "aws_lambda_function" "image_processor" {
  # ... other configuration
  
  reserved_concurrent_executions = 10  # Adjust based on needs
}
```

### Performance Characteristics

| Metric | Value |
|--------|-------|
| Cold Start | ~470ms |
| Warm Execution | 300-600ms per image |
| Memory Usage | ~113 MB average |
| Processing Time | ~100ms per variant |
| Max Image Size | 10 MB (recommended) |

### Scaling Behavior

- **Automatic Scaling**: Lambda scales automatically based on event volume
- **Concurrent Executions**: Up to 10 (configurable)
- **Throttling**: Requests queued when limit reached

## Monitoring & Observability

### CloudWatch Metrics

```bash
# Key metrics to monitor
aws cloudwatch list-metrics \
  --namespace AWS/Lambda \
  --metric-name Invocations,Errors,Duration,Throttles
```

### Recommended Alarms

| Alarm | Condition | Action |
|-------|-----------|--------|
| Error Rate | Errors > 5% for 5 minutes | SNS notification |
| Duration | Duration > 30 seconds | SNS notification |
| Throttling | Throttles > 0 | Investigate concurrency |
| Invocation Spike | Invocations > 1000/min | Review usage patterns |

### Log Analysis

```bash
# View Lambda logs
aws logs tail /aws/lambda/image-processor --follow

# Search for errors
aws logs filter-log-events \
  --log-group-name /aws/lambda/image-processor \
  --filter-pattern "ERROR"
```

## Cost Estimation

### Monthly Cost Breakdown (1,000 images/month)

| Service | Usage | Cost |
|---------|-------|------|
| S3 Storage | ~500 MB | $0.012 |
| S3 PUT Requests | 1,000 | $0.0004 |
| S3 GET Requests | ~5,000 | $0.002 |
| Lambda Invocations | 1,000 | Free (first 1M) |
| Lambda Duration | ~500 GB-s | Free (first 400K GB-s) |
| CloudWatch Logs | ~100 MB | $0.50 |
| **Total** | | **~$0.52** |

### Cost Optimization Tips

1. **S3 Lifecycle Policies**: Move old images to S3 Glacier
2. **Lambda Provisioned Concurrency**: Enable for consistent performance
3. **CloudWatch Logs Retention**: Reduce to 7 days for non-production
4. **S3 Intelligent-Tiering**: Auto-optimize storage costs

## Terraform Resources

### Main Components

```hcl
# S3 Buckets
resource "aws_s3_bucket" "upload" {
  bucket = "image-upload-${var.environment}"
}

resource "aws_s3_bucket" "processed" {
  bucket = "image-processed-${var.environment}"
}

# Lambda Function
resource "aws_lambda_function" "image_processor" {
  function_name = "image-processor"
  runtime       = "python3.12"
  memory_size   = 1024
  timeout       = 60
  
  environment {
    variables = {
      PROCESSED_BUCKET = aws_s3_bucket.processed.id
      LOG_LEVEL        = "INFO"
    }
  }
}

# S3 Event Notification
resource "aws_s3_bucket_notification" "upload_notification" {
  bucket = aws_s3_bucket.upload.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

# IAM Role
resource "aws_iam_role" "lambda_exec" {
  name = "image-processor-role"
}

resource "aws_iam_role_policy" "lambda_policy" {
  # See security section for full policy
}
```

## Disaster Recovery

### Backup Strategy

| Component | Strategy |
|-----------|----------|
| S3 Buckets | Versioning enabled, cross-region replication (optional) |
| Lambda Code | Stored in Git, deployable via Terraform |
| Terraform State | Remote state (S3 with DynamoDB locking) |

### Recovery Point Objectives

| Metric | Target |
|--------|--------|
| RPO (Recovery Point Objective) | 1 hour (with cross-region replication) |
| RTO (Recovery Time Objective) | 15 minutes (with Terraform) |

## Future Enhancements

### Planned Features

- [ ] **Image Recognition**: Integrate Amazon Rekognition for auto-tagging
- [ ] **Content Moderation**: Add content moderation with AWS Rekognition
- [ ] **Face Detection**: Detect and blur faces for privacy
- [ ] **Video Processing**: Extend to support video thumbnails
- [ ] **PDF Processing**: Convert PDF pages to images
- [ ] **CDN Integration**: CloudFront for fast delivery
- [ ] **Webhooks**: Notify external services on completion

### Alternative Architectures

For higher throughput requirements:

1. **AWS Batch**: For batch processing large volumes
2. **ECS/Fargate**: For longer-running processing jobs
3. **Step Functions**: For complex workflow orchestration
4. **EventBridge**: For event-driven architectures

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Lambda timeout | Large image size | Increase timeout or reduce image size |
| Permission denied | Missing IAM policy | Verify Lambda execution role |
| Cold start latency | No requests for period | Enable provisioned concurrency |
| Out of memory | Image too large | Increase Lambda memory or limit image size |

### Debug Commands

```bash
# Check Lambda configuration
aws lambda get-function --function-name image-processor

# View recent invocations
aws lambda invoke \
  --function-name image-processor \
  --log-type Tail \
  /dev/stdout

# Check S3 bucket configuration
aws s3api get-bucket-notification \
  --bucket image-upload-{account}
```

## Conclusion

This serverless image processing architecture provides a cost-effective, scalable solution for automated image optimization. The system requires minimal operational overhead and scales automatically with usage. With proper monitoring and security configurations, it serves as a production-ready foundation for image processing workflows.

---

*Document Version: 1.0*  
*Last Updated: 2026-03-17*  
*Architecture: Serverless / Event-Driven*
