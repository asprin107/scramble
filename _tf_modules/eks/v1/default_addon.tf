### CoreDNS ###
# Change default coreDNS can be deployed fargate. (default can only deploy to ec2. "eks.amazonaws.com/compute-type : ec2")
#kubectl patch deployment coredns \
#  -n kube-system \
#  --type json \
#  -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
resource "aws_eks_addon" "coredns" {
  addon_name                  = "coredns"
  cluster_name                = aws_eks_cluster.main.name
  addon_version               = var.coredns_addon_version // default for EKS v1.27.
  resolve_conflicts_on_create = "OVERWRITE"
  configuration_values = jsonencode({
    computeType = "Fargate"
  })

  tags = var.tags

  depends_on = [aws_eks_fargate_profile.fargate]
}


### LoadBalancer Controller ###
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.main.name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lb_controller.arn
  }

  set {
    name  = "region"
    value = data.aws_region.current.name
  }

  set {
    name  = "vpcId"
    value = var.eks_vpc_id
  }

  depends_on = [aws_eks_fargate_profile.fargate, aws_eks_addon.coredns]
}
# LoadBalancer Controller IRSA
resource "aws_iam_role" "lb_controller" {
  name               = "AmazonEKSLoadBalancerControllerRole-${local.naming_rule}"
  assume_role_policy = data.aws_iam_policy_document.lb_controller_trusted.json

  tags = var.tags
}
resource "aws_iam_policy" "lb_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy-${local.naming_rule}"
  policy = file("${path.module}/resources/iam_policy/lb_controller_policy.json")

  tags = var.tags
}
resource "aws_iam_role_policy_attachment" "lb_controller" {
  role       = aws_iam_role.lb_controller.name
  policy_arn = aws_iam_policy.lb_controller.arn
}


### Fargate Logging ###
# Fargate logging Configuration. See https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/fargate-logging.html
resource "kubernetes_namespace_v1" "fargate_logging" {
  metadata {
    name = "aws-observability"
    labels = {
      aws-observability = "enabled"
    }
  }
}
resource "kubernetes_config_map_v1" "fargate_logging" {
  metadata {
    name      = "aws-logging"
    namespace = kubernetes_namespace_v1.fargate_logging.metadata[0].name
  }
  data = {
    flb_log_cw     = "false" # Set to true to ship Fluent Bit process logs to CloudWatch.
    "filters.conf" = templatefile("${path.module}/resources/fluentbit/cloudwatch/filters.conf.tftpl", {})
    "output.conf" = templatefile("${path.module}/resources/fluentbit/cloudwatch/output.conf.tftpl", {
      aws_region = data.aws_region.current.name
    })
    "parsers.conf" = templatefile("${path.module}/resources/fluentbit/cloudwatch/parsers.conf.tftpl", {})
  }
}


### EKS aws-auth
resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  force = true
  data = {
    mapRoles = yamlencode(concat(
      [
        # Default. Fargate profile
        {
          rolearn  = aws_iam_role.fargate_exec.arn
          username = "system:node:{{SessionName}}"
          groups = [
            "system:bootstrappers",
            "system:nodes",
            "system:node-proxier",
          ]
        }
      ],
      # Admin user role
      [for user_role_arn in var.eks_admin_user_role_arn : {
        rolearn  = user_role_arn
        username = "admin"
        groups   = ["system:masters"]
      }],
      # Custom RBAC
      var.eks_custom_rbac
    ))
  }
}