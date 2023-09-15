module "tags" {
  source = "../../../../_tf_modules/tags/v1"

  project     = local.project
  env         = local.env
  aws_profile = local.aws_profile
}