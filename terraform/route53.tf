data "aws_route53_zone" "registry" {
  name         = var.hosted_zone_name
  private_zone = false
}
