data "aws_route53_zone" "registry" {
  name         = var.hosted_zone_name
  private_zone = false
}


resource "aws_route53_record" "registry" {
  zone_id = data.aws_route53_zone.registry.zone_id
  name    = var.registry_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.registry.domain_name
    zone_id                = aws_cloudfront_distribution.registry.hosted_zone_id
    evaluate_target_health = true
  }
}
