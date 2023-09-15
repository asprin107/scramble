resource "argocd_application" "app-of-apps" {
  metadata {
    name      = "app-of-apps-k6"
    namespace = local.argocd_namespace
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = local.argocd_namespace
    }

    source {
      repo_url        = "https://github.com/asprin107/chaos-engineering.git"
      path            = "helm/eks/app-of-apps"
      target_revision = "feature/eks"
      helm {
        values = templatefile("${path.module}/resources/values.yaml.tftpl", {
          prometheus_role_arn = aws_iam_role.irsa-prometheus.arn
          volume_size         = "20Gi"
        })
      }
    }

    sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
      retry {
        limit = "2"
        backoff {
          duration     = "30s"
          max_duration = "1m"
          factor       = "2"
        }
      }
    }
  }
}

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "argocd.argoproj.io/instance" = "app-of-apps-k6"
    }
  }
}