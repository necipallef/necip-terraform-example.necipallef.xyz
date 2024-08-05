locals {
  domain              = "necip-terraform-example.necipallef.xyz"
  origin_id           = "necipallef-xyz-hello.s3.us-east-1.amazonaws.com"
  s3_cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  acm_certificate_arn = "arn:aws:acm:us-east-1:872196661402:certificate/1dfcb98f-ab6c-4191-a537-611bd2be0796"
}

resource "aws_cloudfront_origin_access_control" "necipallef-xyz-s3-access-control" {
  name                              = "${local.origin_id} OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cloudfront_dist" {
  comment = "created via Terraform"

  aliases             = [local.domain]
  default_root_object = "index.html"

  origin {
    domain_name              = local.origin_id
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.necipallef-xyz-s3-access-control.id
  }

  enabled = true

  http_version = "http2"

  price_class = "PriceClass_100"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = local.s3_cache_policy_id
  }

  viewer_certificate {
    acm_certificate_arn = local.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
