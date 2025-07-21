################################################################################
# ARGOCD apps pour tester le déploiement de helm charts
################################################################################

resource "kubernetes_manifest" "test_argo_app_of_apps" {
  #for_each = toset(var.stages)
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "test-argocd-${terraform.workspace}"
      namespace = "argocd"
      labels = {
        "app.kubernetes.io/name"    = "test-argocd-${terraform.workspace}"
        "app.kubernetes.io/part-of" = "xroad-${terraform.workspace}"
      }
    }
    spec = {
      project = "${terraform.workspace}"
      source = {
        repoURL        = var.repo_github_url
        targetRevision = var.target_revision
        path           = var.chart_path
        helm = {
          values = yamlencode({
            server_image_test_argo   = var.server_image
            image_tag_test_argo     = var.image_tag
            ingress = {
              annotations = {
                subnetAllowList   = "${module.sea_network.web_subnet_a.id}, ${module.sea_network.web_subnet_b.id}"
                acmCertificateArn = var.acm_certificate_arn
              }
            }
          })
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "xroad-${terraform.workspace}"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
  depends_on = [
    kubernetes_manifest.argocd_project
  ]
}
