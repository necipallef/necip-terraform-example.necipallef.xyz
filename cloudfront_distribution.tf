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

  #region fingerprint start

  origin {
    domain_name = "fpcdn.io"
    origin_id   = local.fpcdn_origin_id
    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2"]
    }
    custom_header {
      name  = "FPJS_SECRET_NAME"
      value = module.fingerprint_cloudfront_integration.fpjs_secret_manager_arn
    }
  }

  ordered_cache_behavior {
    path_pattern = "fpjs_integration/*"

    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = module.fingerprint_cloudfront_integration.fpjs_cache_policy_id
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # Default AllViewer policy
    target_origin_id         = local.fpcdn_origin_id
    viewer_protocol_policy   = "https-only"
    compress                 = true

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = module.fingerprint_cloudfront_integration.fpjs_proxy_lambda_arn
      include_body = true
    }
  }

  #endregion

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
