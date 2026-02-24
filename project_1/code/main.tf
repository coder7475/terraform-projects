// Define the AWS S3 bucket resource
resource "aws_s3_bucket" "firstbucket" {
  bucket = var.bucket_name

    tags = {
      Name        = var.bucket_name
      Environment = var.env
    }
}

// Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.firstbucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


//  Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.firstbucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

// Enable server-side encryption on the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.firstbucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


// Create a CloudFront Origin Access Control (OAC) for the S3 bucket
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "firstbucket-oac"
  description                       = "OAC for firstbucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}



// aws s3 bucket policy to allow CloudFront to access the bucket
resource "aws_s3_bucket_policy" "first_bucket_policy" {
  bucket = aws_s3_bucket.firstbucket.id
  depends_on = [ 
    aws_s3_bucket_public_access_block.public_access_block, aws_cloudfront_origin_access_control.oac 
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          AWS = "cloudfront.amazonaws.com"
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = "${aws_s3_bucket.firstbucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/*"
          }
        }
      }
    ]
  })
}

//
resource "aws_s3_object" "object" {
  for_each = fileset("${path.module}/www", ["*.**"])
  bucket = aws_s3_bucket.firstbucket.id
  key    = each.value
  source = "${path.module}/www/${each.value}"

  etag = filemd5("${path.module}/www/${each.value}")

  content_type = lookup({
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript",
    "json" = "application/json",
    "png"  = "image/png",
    "jpg"  = "image/jpeg",
    "jpeg" = "image/jpeg",
    "gif"  = "image/gif",
    "svg"  = "image/svg+xml",
    "ico"  = "image/x-icon",
    "txt"  = "text/plain"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}

// create cloudfront distribution to serve the content from the S3 bucket
