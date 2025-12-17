# 1. Create the Route 53 Zone (The "House" for your DNS)
resource "aws_route53_zone" "main" {
  name = "talhairving.com"
}

# 2. Request the Certificate (The "ID Card")
# (This replaces your manual request - much cleaner for employers to see)
# CloudFront requires certificates in us-east-1
resource "aws_acm_certificate" "root_cert" {
  provider          = aws.us_east_1
  domain_name       = "talhairving.com"
  validation_method = "DNS"
  subject_alternative_names = ["www.talhairving.com"]

  lifecycle {
    create_before_destroy = true
  }
}

# 3. Create the Validation Record (The "Proof" you own the domain)
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.root_cert.domain_validation_options : dvo.domain_name => dvo
  }

  allow_overwrite = true
  name            = each.value.resource_record_name
  records         = [each.value.resource_record_value]
  ttl             = 60
  type            = each.value.resource_record_type
  zone_id         = aws_route53_zone.main.zone_id
}

# 4. Wait for Validation (The "Guard" that waits until it's approved)
# COMMENTED OUT: Uncomment after updating domain nameservers at registrar to point to Route53
# resource "aws_acm_certificate_validation" "root_cert_valid" {
#   provider                  = aws.us_east_1
#   certificate_arn           = aws_acm_certificate.root_cert.arn
#   validation_record_fqdns   = [for record in aws_route53_record.cert_validation : record.fqdn]
# }


# 5. Alias record pointing domain to CloudFront
resource "aws_route53_record" "domain_alias" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "talhairving.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.portfolio_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# 6. CNAME record for www subdomain
resource "aws_route53_record" "www_cname" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.talhairving.com"
  type    = "CNAME"
  ttl     = 300
  records = ["talhairving.com"]
}