resource "aws_acm_certificate" "registry" {
  domain_name       = var.registry_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "registry_acm" {
  for_each = {
    for dvo in aws_acm_certificate.registry.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.registry.zone_id
}

resource "aws_acm_certificate_validation" "registry" {
  certificate_arn         = aws_acm_certificate.registry.arn
  validation_record_fqdns = [for record in aws_route53_record.registry_acm : record.fqdn]

  timeouts {
    create = "5m"
  }
}
