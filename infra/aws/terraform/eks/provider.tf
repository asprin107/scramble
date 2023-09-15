terraform {
  // Customize your own Terraform configuration.
  // By default, if you don't specify a remote backend configuration for storing the state file, Terraform will store it locally on your machine.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region

  default_tags {
    tags = module.tags.default_tags
  }
}

provider "kubernetes" {
  host                   = module.eks.eks_info.endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_info.kubeconfig_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.eks_info.cluster_name, "--profile", var.aws_profile]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.eks_info.endpoint
    cluster_ca_certificate = base64decode(module.eks.eks_info.kubeconfig_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.eks_info.cluster_name, "--profile", var.aws_profile]
      command     = "aws"
    }
  }
}