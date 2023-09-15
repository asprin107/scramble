locals {
  project     = data.terraform_remote_state.eks.outputs.variable.project
  env         = data.terraform_remote_state.eks.outputs.variable.env
  aws_region  = data.terraform_remote_state.eks.outputs.variable.aws_region
  aws_profile = data.terraform_remote_state.eks.outputs.variable.aws_profile
}