resource "argocd_application" "add-on" {
  metadata {
    name      = "add-on"
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
      path            = "helm/eks/add-on-fargate"
      target_revision = "feature/eks"

      helm {
        values = templatefile("${path.module}/resources/values_add_on.yaml.tftpl", {
          storage_size = "20Gi"
          efs_id       = "${aws_efs_file_system.prometheus.id}::${aws_efs_access_point.prometheus_data.id}" // volumeHandle: [FileSystemId]::[AccessPointId]
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

  timeouts {
    create = "600s"
  }
}