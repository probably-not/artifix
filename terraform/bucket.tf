resource "aws_s3_bucket" "registry" {
  bucket_prefix = var.registry_bucket_prefix
  bucket        = var.registry_bucket_name
  tags          = var.registry_bucket_tags
}

resource "aws_s3_bucket_versioning" "registry" {
  bucket = aws_s3_bucket.registry.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "registry" {
  bucket = aws_s3_bucket.registry.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "registry" {
  depends_on = [aws_s3_bucket_ownership_controls.registry]

  bucket = aws_s3_bucket.registry.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "registry" {
  bucket = aws_s3_bucket.registry.id

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "registry" {
  bucket = aws_s3_bucket.registry.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
