resource "aws_cloudfront_key_value_store" "auth_keys" {
  name    = "HexRegistryAuthKeys"
  comment = "A key value store to hold the Hex Registry auth keys."
}

locals {
  auth_keys_map = {
    for key in split(",", var.auth_keys_str) : sha256(key) => key
  }
}

resource "aws_cloudfrontkeyvaluestore_key" "auth_keys" {
  for_each            = local.auth_keys_map
  key_value_store_arn = aws_cloudfront_key_value_store.auth_keys.arn
  key                 = each.value
  value               = "true"
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
      keyvaluestore_id = aws_cloudfront_key_value_store.auth_keys.id,
      has_auth_keys    = length(local.auth_keys)
    }
  )

  key_value_store_associations = [aws_cloudfront_key_value_store.auth_keys.arn]
}
