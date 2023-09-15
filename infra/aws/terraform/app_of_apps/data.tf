# Below is default remote state. If you store the terraform state in another location for creating kubernetes cluster, you have to set it correctly.
data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "${path.cwd}/../eks/terraform.tfstate"
  }
}

data "aws_caller_identity" "current" {}