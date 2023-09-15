terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "6.0.2"
    }
  }
}