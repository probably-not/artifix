output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.registry.id
}

output "s3_registry_bucket_name" {
  value = aws_s3_bucket.registry.id
}
