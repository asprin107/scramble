module "network" {
  source = "../../../../_tf_modules/network/basic/v1"

  aws_region = var.aws_region
  tags       = module.tags.default_tags
}