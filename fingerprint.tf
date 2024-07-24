module "fingerprint_cloudfront_integration" {
  source = "git@github.com:necipallef/terraform-module-proxy-lambda.git/?ref=v0.7.1"

  fpjs_agent_download_path = "agent"
  fpjs_get_result_path     = "result"
  fpjs_shared_secret       = "secret"
}
