terraform {
  backend "s3" {
    workspace_key_prefix = "environments"
    key                  = "projects/base/test-argocd/terraform.tfstate"
    region               = "ca-central-1" 
  }
}