module "eks" {
  source = "../../../../_tf_modules/eks/v1"

  eks_fargate_namespaces = [
    "k6",
    "k6-operator-system",
    "argocd",
    "monitoring"
  ]
  eks_public_access_cidrs = var.public_cidrs_allowed_access
  eks_subnet_ids          = module.network.subnets_private_ids
  eks_version             = "1.27"
  eks_vpc_id              = module.network.main_vpc_id
  eks_lb_subnet_ids       = module.network.subnets_public_ids

  eks_admin_user_role_arn = var.eks_admin_user_role_arn
  eks_custom_rbac         = var.eks_custom_rbac

  tags = module.tags.default_tags

  depends_on = [module.network]
}