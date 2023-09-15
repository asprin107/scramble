resource "aws_eks_cluster" "main" {
  name                      = local.naming_rule
  version                   = var.eks_version
  role_arn                  = aws_iam_role.eks_cluster.arn
  enabled_cluster_log_types = var.eks_control_plane_log_types

  vpc_config {
    subnet_ids              = var.eks_subnet_ids
    security_group_ids      = [aws_security_group.eks.id] // This security group is intended for cross-account use. Only custom node group can use this.
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.eks_public_access_cidrs
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_cluster.arn
    }
    resources = ["secrets"]
  }

  tags = var.tags
}

resource "aws_eks_fargate_profile" "fargate" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "fargate_profile"
  pod_execution_role_arn = aws_iam_role.fargate_exec.arn

  subnet_ids = var.eks_subnet_ids

  selector {
    namespace = "kube-system"
  }

  dynamic "selector" {
    for_each = var.eks_fargate_namespaces
    content {
      namespace = selector.value
    }
  }

  tags = var.tags
}

data "tls_certificate" "main" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.main.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.main.url

  tags = var.tags
}