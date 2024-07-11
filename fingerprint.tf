module "fingerprint_cloudfront_integration" {
  source = "git@github.com:necipallef/terraform-module-proxy-lambda.git/?ref=v0.3.0"
  create_new_distribution = false
  fpjs_agent_download_path = "agent"
  fpjs_get_result_path = "result"
  fpjs_pre_shared_secret = "secret"
}

locals {
  fpcdn_origin_id = "fpcdn.io"
}
