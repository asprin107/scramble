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
    argocd = {
      source  = "oboukili/argocd"
      version = "6.0.2"
    }
  }
}

provider "aws" {
  profile = local.aws_profile
  region  = local.aws_region

  default_tags {
    tags = module.tags.default_tags
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.eks_info.host
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.eks_info.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.eks_info.cluster_name, "--profile", local.aws_profile]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.eks_info.host
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.eks_info.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.eks_info.cluster_name, "--profile", local.aws_profile]
      command     = "aws"
    }
  }
}

provider "argocd" {
  server_addr = data.terraform_remote_state.eks.outputs.argocd_info.server_addr
  username    = data.terraform_remote_state.eks.outputs.argocd_info.username
  password    = data.terraform_remote_state.eks.outputs.argocd_password
  insecure    = data.terraform_remote_state.eks.outputs.argocd_info.insecure
  plain_text  = data.terraform_remote_state.eks.outputs.argocd_info.plain_text
}