output "website_endpoint" {
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
  description = "S3 static website hosting endpoint"
}

output "bucket_name" {
  value       = aws_s3_bucket.frontend.id
  description = "Name of the S3 bucket"
}

output "cloudfront_distribution_domain" {
  value       = aws_cloudfront_distribution.frontend.domain_name
  description = "CloudFront distribution domain name"
}

output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.frontend.id
  description = "CloudFront distribution ID"
}