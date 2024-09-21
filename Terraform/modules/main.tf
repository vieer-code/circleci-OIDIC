locals {
  circleci_oidc_url = "oidc.circleci.com/org/${var.circleci_org_id}"
  assume_role_value = "org/${var.circleci_org_id}/project/${var.circleci_project_id}/user/*"
}

# Identity Provider
resource "aws_iam_openid_connect_provider" "circleci" {
  url = "https://${local.circleci_oidc_url}"

  client_id_list = [
    var.circleci_org_id,
  ]

  thumbprint_list = [for thumbprint in var.thumbprints : thumbprint]
}


# Role's permissions
data "aws_iam_policy_document" "circleci" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.circleci.arn]
    }

    condition {
      test     = "StringLike"
      variable = "${local.circleci_oidc_url}:sub"
      values   = [local.assume_role_value]
    }
  }
}

resource "local_file" "example" {
  filename = "./Trust-relationships.json"
  content  = data.aws_iam_policy_document.circleci.json
}
# Variables block
variable "circleci_org_id" {
  type        = string
  description = "The UUID formatted Organization ID from CircleCI"
}

variable "circleci_project_id" {
  type        = string
  description = "The UUID formatted Project ID from CircleCI"
}

variable "thumbprints" {
  type        = list(string)
  description = "The OIDC thumbprints used for the OIDC provider (default)"
  default     = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}
