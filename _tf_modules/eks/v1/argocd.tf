resource "kubernetes_namespace_v1" "argocd" {
  count = var.argocd.enabled ? 1 : 0

  metadata {
    name = var.argocd.namespace
  }

  depends_on = [aws_eks_fargate_profile.fargate]
}

# ArgoCD application
resource "helm_release" "argocd" {
  count = var.argocd.enabled ? 1 : 0

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = var.argocd.namespace
  create_namespace = false

  values = [templatefile("${path.module}/resources/argocd/values.yaml.tftpl", {
    lb_name            = "${local.naming_rule}-argocd"
    lb_subnets         = join(", ", var.eks_lb_subnet_ids)
    lb_security_groups = join(", ", [aws_security_group.elb.id])
  })]

  depends_on = [
    kubernetes_namespace_v1.argocd,
    aws_eks_addon.coredns,
    helm_release.aws_load_balancer_controller
  ]
}


data "kubernetes_secret" "argocd-initial-pwd" {
  count = var.argocd.enabled ? 1 : 0

  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.argocd.namespace
  }
  depends_on = [helm_release.argocd]
}

data "kubernetes_service_v1" "svc-argocd-server" {
  count = var.argocd.enabled ? 1 : 0

  metadata {
    name      = "argocd-server"
    namespace = var.argocd.namespace
  }
  depends_on = [helm_release.argocd]
}