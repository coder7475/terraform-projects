# S3 Bucket Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.firstbucket.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.firstbucket.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.firstbucket.bucket_domain_name
}

# CloudFront Distribution Outputs
output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.arn
}

output "website_url" {
  description = "URL of the website served through CloudFront"
  value       = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}