resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  create_namespace = true
  namespace        = "nginx-ingress"

  depends_on = [module.eks]
}


resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  create_namespace = true
  namespace        = "cert-manager"

  set = [{
    name  = "crds.enabled"
    value = "true"
  }]

  values = [
    file("./helm-values/cert-manager.yaml")
  ]

}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"

  create_namespace = true
  namespace        = "external-dns"
  replace          = true

  depends_on = [module.external_dns_irsa_role]

  values = [
    file("./helm-values/external-dns.yaml")
  ]

}

resource "helm_release" "argocd_deploy" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  timeout    = 1200
  version    = "7.7.9"

  create_namespace = true
  namespace        = "argo-cd"

  values = [
    file("./helm-values/argocd.yaml")
  ]

  depends_on = [helm_release.nginx_ingress, helm_release.cert_manager, helm_release.external_dns]


}

resource "helm_release" "kube_prom_stack" {
  name       = "monitoring-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  create_namespace = true
  namespace        = "monitoring"

  values = [
    file("./helm-values/monitoring.yaml")
  ]

  depends_on = [helm_release.nginx_ingress, helm_release.cert_manager, helm_release.external_dns]

}
