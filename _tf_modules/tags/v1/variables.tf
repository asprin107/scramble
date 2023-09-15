variable "project" {
  description = "The project name. It used to every resources name prefix."
  type        = string
}

variable "env" {
  description = "System environment."
  type        = string
}

variable "aws_profile" {
  description = "AWS profile name."
  type        = string
}