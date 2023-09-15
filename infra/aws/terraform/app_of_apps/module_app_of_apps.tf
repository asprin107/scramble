module "app_of_apps" {
  source = "../../../../_tf_modules/app_of_apps/k6/v1"

  eks_oidc_provider_info = {
    arn = data.terraform_remote_state.eks.outputs.eks_info.oidc_provider_arn
    name = replace(
      data.terraform_remote_state.eks.outputs.eks_info.oidc_provider_arn,
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/",
      ""
    )
  }
  eks_subnet_ids = data.terraform_remote_state.eks.outputs.network.eks_subnet_ids
  vpc_id         = data.terraform_remote_state.eks.outputs.network.vpc_id
  elb_arn        = data.terraform_remote_state.eks.outputs.eks_info.elb_arn

  tags = module.tags.default_tags
}