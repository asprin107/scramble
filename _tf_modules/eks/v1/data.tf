data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "main" {
  id = var.eks_vpc_id
}

data "aws_iam_policy_document" "eks_trusted" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "kms_for_eks" {
  statement {
    sid = "EnableIAMUserPermissions"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "fargate" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lb_controller_trusted" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [local.eks_oidc_provider.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_provider.name}:aud" // Set oidc provider name from arn.
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_provider.name}:sub" // Set oidc provider name from arn.
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}