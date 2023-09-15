# Managed Node Group use auto generated security group only. (Fargate)
# Auto generated security group has egress to all basically.
data "aws_security_group" "eks_auto_generated" {
  id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}


resource "aws_security_group_rule" "elb" {
  security_group_id        = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.elb.id
}

resource "aws_security_group" "eks" {
  name = "seg-${local.naming_rule}-eks"

  description = "default sg for eks."
  vpc_id      = var.eks_vpc_id

  ingress {
    description = "Allow ingress all from private network."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  ingress {
    description     = "Allow ingress all from ELB."
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.elb.id]
  }

  egress {
    description = "Allow egress to all."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "seg-${local.naming_rule}-eks"
    }
  )
}


resource "aws_security_group" "elb" {
  name        = "seg-${local.naming_rule}-eks-elb"
  description = "Default sg for eks ELB."
  vpc_id      = var.eks_vpc_id

  ingress {
    description = "Allow argocd web protocol from valid office."
    from_port   = 80
    to_port     = 84
    protocol    = "tcp"
    cidr_blocks = var.eks_public_access_cidrs
  }

  ingress {
    description = "Allow argocd grpc protocol from valid office."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.eks_public_access_cidrs
  }

  egress {
    description = "Allow egress to all."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "seg-${local.naming_rule}-eks-elb"
    }
  )
}