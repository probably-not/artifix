resource "aws_cloudfront_origin_access_control" "registry" {
  name                              = "registry"
  description                       = "The Hex Registry Origin Access Control definition"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "registry" {
  origin {
    domain_name              = aws_s3_bucket.registry.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.registry.id
    origin_id                = "HexRegistryOrigin"
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "The Hex Registry CDN distribution"

  aliases = [var.registry_domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "HexRegistryOrigin"

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    # This is the Managed-CachingOptimized policy for optimal caching of S3 assets
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    # This is the Managed-CORS-S3Origin policy
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"

    # This is the Managed-CORS-with-preflight-and-SecurityHeadersPolicy policy
    response_headers_policy_id = "eaab4381-ed33-4a86-88ca-d9558dc6cd63"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.registry.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
