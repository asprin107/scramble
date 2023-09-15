variable "tags" {
  description = "Default tags."
  type = object({
    Project     = string // Project name.
    Profile     = string // AWS profile name.
    Environment = string // System Environment.
  })
}

variable "eks_subnet_ids" {
  description = "List subnet ids for eks data plane will be deployed. These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER_NAME (Fargate)"
  type        = list(string)
}

variable "eks_version" {
  description = "EKS kubernetes version."
  type        = string
  default     = "1.27"
}

variable "coredns_addon_version" {
  description = "CoreDNS addon version for EKS."
  type        = string
  default     = "v1.10.1-eksbuild.3"
}

variable "eks_public_access_cidrs" {
  description = "List CIDR where can access the eks cluster."
  type        = list(string)
}

variable "eks_control_plane_log_types" {
  description = "EKS control plane log types. Default value is [] which means not logging. More details. https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html"
  default     = [] # ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  type        = list(string)
}

variable "eks_fargate_namespaces" {
  description = "EKS Namespaces for fargate nodegroup. A maximum of 4 elements can be set. Fargate allowed 5 namespaces. By default, in this module, 'kube-system' namespace already added."
  type        = list(string)
}

variable "eks_vpc_id" {
  description = "VPC id for EKS."
  type        = string
}

variable "eks_lb_subnet_ids" {
  description = "Subnet ids for nlb."
  type        = list(string)
}

variable "argocd_enabled" {
  description = "ArgoCD enabled option. Default is true."
  default     = true
  type        = bool
}

variable "argocd" {
  description = "Variables related to ArgoCD."
  default = {
    service_port     = 80
    service_tls_port = 443
    namespace        = "argocd"
    enabled          = true
  }
  type = object({
    service_port     = number
    service_tls_port = number
    namespace        = string
    enabled          = bool
  })
}

variable "eks_admin_user_role_arn" {
  description = "EKS admin user role arn list."
  default     = []
  type        = list(string)
}

variable "eks_custom_rbac" {
  description = "Custom RBAC would be saved in aws-auth configmap. See https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html and https://kubernetes.io/docs/reference/access-authn-authz/rbac/"
  default     = []
  type        = any
}