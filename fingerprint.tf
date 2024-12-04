module "fingerprint_cloudfront_integration" {
  source = "git@github.com:fingerprintjs/terraform-aws-fingerprint-cloudfront-proxy-integration.git/?ref=v0.1.0"

  fpjs_agent_download_path = "agent"
  fpjs_get_result_path     = "result"
  fpjs_shared_secret       = "secret"
}
