output "eks_info" {
  value = {
    cluster_name                          = aws_eks_cluster.main.name
    endpoint                              = aws_eks_cluster.main.endpoint
    oidc_provider_arn                     = aws_iam_openid_connect_provider.oidc_provider.arn
    kubeconfig_certificate_authority_data = aws_eks_cluster.main.certificate_authority[0].data
    elb = {
      arn   = aws_lb.eks.id
      dns   = aws_lb.eks.dns_name
      sg_id = aws_security_group.elb.id
    }
  }
}

output "argocd_info" {
  value = {
    server_addr = format("%s%s", data.kubernetes_service_v1.svc-argocd-server[0].status[0].load_balancer[0].ingress[0].hostname, ":${var.argocd.service_port}")
    username    = "admin"
    insecure    = true
    plain_text  = true
  }
}

output "argpcd_password" {
  value     = data.kubernetes_secret.argocd-initial-pwd[0].data.password
  sensitive = true
}