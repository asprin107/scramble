module "tags" {
  source = "../../../../_tf_modules/tags/v1"

  project     = var.project
  env         = var.env
  aws_profile = var.aws_profile
}