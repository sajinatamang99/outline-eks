terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.cluster.certificate_authority[0].data
  )
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.cluster.certificate_authority[0].data
    )
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Use the Terraform Helm provider to install Kubernetes add-ons:
resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.13.3"
  depends_on = [
    data.aws_eks_cluster.cluster
  ]

  create_namespace = true
  namespace        = "ingress-nginx"

  values = [
    "${file("${path.module}/values/nginx-ingress.yaml")}"
  ]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  create_namespace = true
  namespace        = "cert-manager"
  depends_on = [
    data.aws_eks_cluster.cluster
  ]

  values = [
    "${file("${path.module}/values/cert-manager.yaml")}"
  ]
}

resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  create_namespace = true
  namespace        = "external-dns"
  depends_on = [
    data.aws_eks_cluster.cluster
  ]

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.external_dns_role_arn
  }
  values = [
    "${file("${path.module}/values/external-dns.yaml")}"
  ]
}

resource "helm_release" "argocd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm/"
  chart      = "argo-cd"
  version    = "5.19.15"
  timeout    = "600"

  create_namespace = true
  namespace        = "argo-cd"

  values = [
    "${file("${path.module}/values/argocd.yaml")}"
  ]

  depends_on = [data.aws_eks_cluster.cluster, helm_release.nginx_ingress, helm_release.cert_manager, helm_release.external_dns]
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "78.3.1"

  create_namespace = true
  namespace        = "monitoring"
  timeout          = 1800

  values = [
    "${file("${path.module}/values/kube-prometheus-stack.yaml")}"
  ]

  depends_on = [data.aws_eks_cluster.cluster, helm_release.nginx_ingress, helm_release.cert_manager, helm_release.external_dns]
}
