resource "aws_cloudfront_key_value_store" "auth_keys" {
  name    = "HexRegistryAuthKeys"
  comment = "A key value store to hold the Hex Registry auth keys."
}

resource "aws_cloudfront_function" "validate_auth_key" {
  name    = "validate_auth_key"
  runtime = "cloudfront-js-2.0"
  comment = "Simple function to validate the auth key for requests to the Hex Registry"
  publish = true
  code = templatefile(
    "${path.module}/validate_auth_key/index.js",
    {
      logging_enabled  = var.enable_cloudfront_function_logging,
      keyvaluestore_id = aws_cloudfront_key_value_store.auth_keys.id
    }
  )

  key_value_store_associations = [aws_cloudfront_key_value_store.auth_keys.arn]
}
