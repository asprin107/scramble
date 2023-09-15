resource "aws_kms_key" "eks_cluster" {
  description              = "KMS key for EKS Cluster."
  deletion_window_in_days  = 7
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  is_enabled               = true
  enable_key_rotation      = false
  policy                   = data.aws_iam_policy_document.kms_for_eks.json

  tags = var.tags
}

resource "aws_kms_alias" "eks_cluster" {
  name          = "alias/${local.naming_rule}-eks"
  target_key_id = aws_kms_key.eks_cluster.id
}