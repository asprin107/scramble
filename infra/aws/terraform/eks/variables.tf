variable "project" {
  description = "The project name. It used to every resources name prefix."
  type        = string
}

variable "env" {
  description = "System environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region name."
  type        = string
}

variable "aws_profile" {
  description = "AWS profile name."
  type        = string
}

variable "public_cidrs_allowed_access" {
  description = "Public CIDR list allowed eks access."
  type        = list(string)
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