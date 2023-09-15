locals {
  default_tags = {
    Project     = var.project
    Environment = var.env
    Profile     = var.aws_profile
  }
}