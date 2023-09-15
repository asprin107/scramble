output "network" {
  value = {
    vpc_id            = module.network.main_vpc_id
    eks_subnet_ids    = module.network.subnets_private_ids
    public_subnet_ids = module.network.subnets_public_ids
  }
}

output "eks_info" {
  value = {
    host                   = module.eks.eks_info.endpoint
    cluster_ca_certificate = module.eks.eks_info.kubeconfig_certificate_authority_data
    cluster_name           = module.eks.eks_info.cluster_name
    oidc_provider_arn      = module.eks.eks_info.oidc_provider_arn
    elb_arn                = module.eks.eks_info.elb.arn
    elb_dns                = module.eks.eks_info.elb.dns
    elb_sg_ids             = [module.eks.eks_info.elb.sg_id]
  }
}

output "argocd_info" {
  value = module.eks.argocd_info
}

output "argocd_password" {
  value     = module.eks.argpcd_password
  sensitive = true
}

output "variable" {
  value = {
    project     = var.project
    env         = var.env
    aws_region  = var.aws_region
    aws_profile = var.aws_profile
  }
}