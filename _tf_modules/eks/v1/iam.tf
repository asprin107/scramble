# EKS Cluster Service Role
resource "aws_iam_role" "eks_cluster" {
  name               = "eks-svc-${local.naming_rule}"
  assume_role_policy = data.aws_iam_policy_document.eks_trusted.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}


# Fargate Execution Role
resource "aws_iam_role" "fargate_exec" {
  name               = "eks-fargate-exec-${local.naming_rule}"
  assume_role_policy = data.aws_iam_policy_document.fargate.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_exec.name
}

resource "aws_iam_role_policy" "fargate_logging" {
  name   = "eks-fargate-logging-${local.naming_rule}"
  policy = file("${path.module}/resources/iam_policy/fargate_exec_policy.json")
  role   = aws_iam_role.fargate_exec.id
}