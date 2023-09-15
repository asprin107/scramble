variable "tags" {
  description = "Default tags."
  type = object({
    Project     = string
    Environment = string
  })
}

variable "eks_subnet_ids" {
  description = "Subnet ids for EKS."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC id for nlb."
  type        = string
}

variable "elb_arn" {
  description = "ELB arn for eks service."
  type        = string
}

variable "eks_oidc_provider_info" {
  description = "EKS OIDC provider."
  type = object({
    arn  = string
    name = string
  })
}