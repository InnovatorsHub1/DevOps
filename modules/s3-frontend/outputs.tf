output "website_endpoint" {
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
  description = "S3 static website hosting endpoint"
}

output "bucket_name" {
  value       = aws_s3_bucket.frontend.id
  description = "Name of the S3 bucket"
}