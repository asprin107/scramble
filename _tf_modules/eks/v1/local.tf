locals {
  naming_rule = "${var.tags.Project}-${var.tags.Environment}"
  eks_oidc_provider = {
    arn = aws_iam_openid_connect_provider.oidc_provider.arn
    name = replace(
      aws_iam_openid_connect_provider.oidc_provider.arn,
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/",
      ""
    )
  }
}