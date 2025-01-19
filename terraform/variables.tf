variable "aws_default_region" {
  description = "AWS Default Region to use. Defaults to us-east-1."
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "The domain name for the created Hex Registry. This value is required."
  type        = string
}
