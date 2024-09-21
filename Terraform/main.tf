module "circleci-aws-oidc" {
  source              = "./modules/"
  circleci_org_id     = "*"
  circleci_project_id = "*"
}