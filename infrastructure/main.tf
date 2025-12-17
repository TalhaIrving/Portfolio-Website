# Portfolio website bucket
resource "aws_s3_bucket" "portfolio_website" {
  bucket = var.website_domain
}

resource "aws_s3_bucket_versioning" "portfolio_website_versioning" {
  bucket = aws_s3_bucket.portfolio_website.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "portfolio_website_encryption" {
  bucket = aws_s3_bucket.portfolio_website.id 

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "portfolio_website_public_access" {
  bucket = aws_s3_bucket.portfolio_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "portfolio_website_config" {
  bucket = aws_s3_bucket.portfolio_website.id

  index_document {
  suffix = "index.html"
  }

  error_document {
  key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "portfolio_website_public_read" {
  bucket = aws_s3_bucket.portfolio_website.id

  policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
    Sid       = "PublicReadGetObject"
    Effect    = "Allow"
    Principal = "*"
    Action    = "s3:GetObject"
    Resource = [
      aws_s3_bucket.portfolio_website.arn,
      "${aws_s3_bucket.portfolio_website.arn}/*",
    ]
    },
  ]
  })

  depends_on = [
  aws_s3_bucket_public_access_block.portfolio_website_public_access
  ]
}

# CloudFront distribution
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "s3-oac-portfolio"
  description                       = "OAC for portfolio S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "portfolio_cdn" {
  enabled             = true
  default_root_object = "index.html"

  aliases = ["talhairving.com", "www.talhairving.com"]

  origin {
    domain_name = aws_s3_bucket.portfolio_website.bucket_regional_domain_name
    origin_id   = "S3-Origin-for-Portfolio"

    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  default_cache_behavior {
    target_origin_id       = "S3-Origin-for-Portfolio"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
        
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
  acm_certificate_arn      = aws_acm_certificate.root_cert.arn
  ssl_support_method       = "sni-only"
  minimum_protocol_version = "TLSv1.2_2021"
 }
}