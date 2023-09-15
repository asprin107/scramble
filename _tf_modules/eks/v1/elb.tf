resource "aws_lb" "eks" {
  name               = local.naming_rule
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.elb.id]
  subnets            = var.eks_lb_subnet_ids
  enable_http2       = true
  ip_address_type    = "ipv4"

  tags = var.tags
}