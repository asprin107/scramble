# Prometheus EFS
resource "aws_efs_file_system" "prometheus" {
  creation_token = "${local.naming_rule}-prometheus"
  encrypted      = true

  tags = var.tags
}

resource "aws_efs_mount_target" "prometheus" {
  count = length(var.eks_subnet_ids)

  file_system_id  = aws_efs_file_system.prometheus.id
  subnet_id       = var.eks_subnet_ids[count.index]
  security_groups = [aws_security_group.efs-prometheus.id]
}

resource "aws_efs_access_point" "prometheus_data" {
  file_system_id = aws_efs_file_system.prometheus.id
  posix_user {
    gid = 65534 // prometheus image:quay.io/prometheus/prometheus default user is "nobody", 65534.
    uid = 65534 // prometheus image:quay.io/prometheus/prometheus default user is "nobody", 65534.
  }
  root_directory {
    creation_info {
      owner_gid   = 65534
      owner_uid   = 65534
      permissions = "755"
    }
    path = "/data" // prometheus need.
  }

  tags = var.tags
}

data "aws_vpc" "eks" {
  id = var.vpc_id
}

resource "aws_security_group" "efs-prometheus" {
  name        = "seg-${local.naming_rule}-eks-efs-prometheus"
  description = "EFS sg for prometheus."
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow access using SFTP in eks cluster."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.eks.cidr_block]
  }
  ingress {
    description = "Allow access using NFS in eks cluster."
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.eks.cidr_block]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

#resource "aws_efs_file_system_policy" "prometheus" {
#  file_system_id = aws_efs_file_system.prometheus.id
#  policy         = data.aws_iam_policy_document.efs-prometheus.json
#}
#
#data "aws_iam_policy_document" "efs-prometheus" {
#  statement {
#    sid = "AllowEFSAccess"
#    principals {
#      type        = "AWS"
#      identifiers = [aws_iam_role.irsa-prometheus.arn]
#    }
#    effect = "Allow"
#    actions = [
#      "elasticfilesystem:ClientMount",
#      "elasticfilesystem:ClientWrite",
#    ]
#    resources = [aws_efs_file_system.prometheus.arn]
#    condition {
#      test     = "Bool"
#      variable = "elasticfilesystem:AccessedViaMountTarget"
#      values   = ["true"]
#    }
#  }
#}


# Prometheus IRSA
resource "aws_iam_role" "irsa-prometheus" {
  name               = "${local.naming_rule}-eks-irsa-prometheus"
  assume_role_policy = data.aws_iam_policy_document.irsa_trusted.json

  tags = var.tags
}

resource "aws_iam_role_policy" "irsa-prometheus-efs" {
  role   = aws_iam_role.irsa-prometheus.id
  policy = data.aws_iam_policy_document.prometheus.json
}

data "aws_iam_policy_document" "irsa_trusted" {
  statement {
    principals {
      type        = "Federated"
      identifiers = [var.eks_oidc_provider_info.arn]
    }
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:monitoring:prometheus-server"]
      variable = "${var.eks_oidc_provider_info.name}:sub"
    }
    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "${var.eks_oidc_provider_info.name}:aud"
    }
  }
}

data "aws_iam_policy_document" "prometheus" {
  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
    ]
    resources = [aws_efs_file_system.prometheus.arn]
    condition {
      test     = "Bool"
      variable = "elasticfilesystem:AccessedViaMountTarget"
      values   = ["true"]
    }
  }
}