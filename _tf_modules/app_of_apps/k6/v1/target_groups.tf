resource "aws_lb_target_group" "apps" {
  for_each    = { for k, v in yamldecode(file("${path.module}/resources/tg_svc.yaml")) : k => v }
  name        = each.key
  target_type = "ip"
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  port        = each.value.service_port

  tags = var.tags
}

resource "aws_lb_listener" "apps" {
  for_each          = { for k, v in yamldecode(file("${path.module}/resources/tg_svc.yaml")) : k => v }
  load_balancer_arn = var.elb_arn
  port              = each.value.listen_port
  protocol          = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.apps[each.key].arn
    type             = "forward"
  }

  tags = var.tags
}

resource "kubernetes_manifest" "apps" {
  for_each = { for k, v in yamldecode(file("${path.module}/resources/tg_svc.yaml")) : k => v if v.public_access == true }
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"
    metadata = {
      name      = each.key
      namespace = each.value.namespace
      labels = {
        "service.k8s.aws/stack-name"      = each.value.service_name
        "service.k8s.aws/stack-namespace" = "monitoring"
      }
    }
    spec = {
      serviceRef = {
        name = each.value.service_name
        port = each.value.service_port
      }
      targetType     = "ip"
      targetGroupARN = aws_lb_target_group.apps[each.key].arn
    }
  }

  depends_on = [kubernetes_namespace_v1.monitoring]
}