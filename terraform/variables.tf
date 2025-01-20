variable "aws_default_region" {
  description = "AWS Default Region to use. Defaults to us-east-1."
  type        = string
  default     = "us-east-1"
}

variable "hosted_zone_name" {
  description = "The name of the Hosted Zone in Route53 where the created Hex Registry will be routed. This value is required."
  type        = string
}

variable "registry_domain_name" {
  description = "The domain name for the created Hex Registry. This value is required."
  type        = string
}

variable "auth_keys_csv" {
  description = "Auth Keys that can be used for authentication with the registry, in a CSV format (so that they may be passed via environment variables). These will be set within a CloudFront KeyValueStore, which will be accessed by the authentication function on requests. This defaults to empty, meaning that there is no authentication check for the registry."
  type        = string
  sensitive   = true
  default     = ""
}

variable "registry_bucket_name" {
  description = "The name of the bucket to be used for the registry. This defaults to empty. It will be auto-generated by Terraform if not provided. It conflicts with the `registry_bucket_prefix`, they should not be set together."
  type        = string
  default     = ""
}

variable "registry_bucket_prefix" {
  description = "The prefix of the name of the bucket to be used for the registry. This defaults to empty. It will be auto-generated by Terraform if not provided. It conflicts with the `registry_bucket_name`, they should not be set together."
  type        = string
  default     = ""
}

variable "registry_bucket_tags" {
  description = "The tags to add to the bucket to be used for the registry. This defaults to an empty map."
  type        = map(string)
  default     = {}
}
